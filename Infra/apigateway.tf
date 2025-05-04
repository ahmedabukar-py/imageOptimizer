resource "aws_apigatewayv2_api" "upload_api" {
  name          = "upload-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "upload_lambda_integration" {
  api_id                 = aws_apigatewayv2_api.upload_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.upload_lambda.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "upload_route" {
  api_id    = aws_apigatewayv2_api.upload_api.id
  route_key = "POST /upload"
  target    = "integrations/${aws_apigatewayv2_integration.upload_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "upload_stage" {
  api_id      = aws_apigatewayv2_api.upload_api.id
  name        = "$default"
  auto_deploy = true
}

# Permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_apigw_invoke_upload" {
  statement_id  = "AllowAPIGatewayInvokeUploadLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.upload_api.execution_arn}/*/*"
}
