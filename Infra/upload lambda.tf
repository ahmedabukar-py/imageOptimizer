resource "aws_lambda_function" "upload_lambda" {
  function_name = "upload_lambda"
  runtime       = "python3.11"
  handler       = "main.lambda_handler"

  filename         = "../lambdas/upload/function.zip"
  source_code_hash = filebase64sha256("../lambdas/upload/function.zip")

  role = aws_iam_role.upload_lambda_role.arn

  timeout     = 10
  memory_size = 128

  depends_on = [aws_iam_role_policy_attachment.upload_lambda_attachment]
}
