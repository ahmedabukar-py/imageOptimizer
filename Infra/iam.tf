// ####################### upload IAM ################################

resource "aws_iam_role" "upload_lambda_role" {
  name = "upload_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "upload_lambda_policy" {
  name = "upload_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Put"
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::image-optimizer-originals/*"
      },
      {
        Sid    = "AllowDynamoDBPut"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/image_uploads"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "upload_lambda_attachment" {
  role       = aws_iam_role.upload_lambda_role.name
  policy_arn = aws_iam_policy.upload_lambda_policy.arn
}

// ####################### optimize IAM ################################


resource "aws_iam_role" "optimize_lambda_role" {
  name = "optimize_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "optimize_lambda_policy" {
  name = "optimize_lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.original_images.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.upload_table.arn
      },
      {
        Effect : "Allow",
        Action : [
          "s3:GetObject",
          "s3:HeadObject",
          "s3:ListBucket"
        ],
        Resource : [
          "arn:aws:s3:::image-optimizer-originals",
          "arn:aws:s3:::image-optimizer-originals/*"
        ]
      },
      {
        Sid    = "AllowDynamoDBPut"
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/image_uploads"
      },
      {
        Sid = "AllowS3PutObject"
        Effect : "Allow",
        Action : "s3:PutObject",
        Resource = ["arn:aws:s3:::image-optimizer-optimized/optimized/*", "arn:aws:s3:::image-optimizer-optimized/*"]
      }

    ]
  })
}

resource "aws_iam_role_policy_attachment" "optimize_lambda_attachment" {
  role       = aws_iam_role.optimize_lambda_role.name
  policy_arn = aws_iam_policy.optimize_lambda_policy.arn
}


// ####################### NEXT IAM ################################
