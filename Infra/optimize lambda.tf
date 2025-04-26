resource "aws_lambda_function" "optimize_lambda" {
  function_name = "optimize_lambda"
  runtime       = "python3.10"
  handler       = "main.lambda_handler"

  filename         = "../lambdas/optimize/function.zip"
  source_code_hash = filebase64sha256("../lambdas/optimize/function.zip")
  environment {
    variables = {
      OPTIMIZED_BUCKET = aws_s3_bucket.optimized_images.bucket
    }
  }


  role = aws_iam_role.optimize_lambda_role.arn

  timeout     = 30
  memory_size = 600

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  depends_on = [aws_iam_role_policy_attachment.optimize_lambda_attachment]
}

resource "aws_lambda_layer_version" "pillow_layer" {
  layer_name          = "pillow-layer"
  compatible_runtimes = ["python3.10"]
  filename            = "../lambdas/optimize/tmp/pillow-layer.zip"
  description         = "Pillow library for image optimization"
}

resource "aws_s3_bucket_notification" "trigger_optimize_lambda" {
  bucket = aws_s3_bucket.original_images.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.optimize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".jpg" # You can add ".png" or remove for all
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.optimize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".jpeg"
  }

  lambda_function {
    lambda_function_arn = aws_lambda_function.optimize_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_optimize]
}

resource "aws_lambda_permission" "allow_s3_invoke_optimize" {
  statement_id  = "AllowS3InvokeOptimize"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.optimize_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.original_images.arn
}
