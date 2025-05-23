provider "aws" {
  region = var.region
}
 
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
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
 
resource "aws_iam_role_policy_attachment" "lambda_basic" {
role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

 data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "hello" {
  function_name = "hello-world"
  handler       = "main.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_exec.arn
  filename = data.archive_file.lambda_zip.output_path
  source_code_hash =data.archive_file.lambda_zip.output_base64sha256
}
 
resource "aws_cognito_user_pool" "user_pool" {
  name = "hello-user-pool"
}
 
resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "hello-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  callback_urls = ["https://example.com/callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid"]
  supported_identity_providers = ["COGNITO"]
}
 
resource "aws_api_gateway_rest_api" "api" {
  name = "hello-api"
}
 
resource "aws_api_gateway_resource" "hello_resource" {
rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}
 
resource "aws_api_gateway_method" "get_hello" {
rest_api_id = aws_api_gateway_rest_api.api.id
resource_id = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
authorizer_id = aws_api_gateway_authorizer.auth.id
}
 
resource "aws_api_gateway_authorizer" "auth" {
  name               = "cognito-authorizer"
rest_api_id = aws_api_gateway_rest_api.api.id
  identity_source    = "method.request.header.Authorization"
  type               = "COGNITO_USER_POOLS"
  provider_arns      = [aws_cognito_user_pool.user_pool.arn]
}
 
resource "aws_api_gateway_integration" "lambda_integration" {
rest_api_id = aws_api_gateway_rest_api.api.id
resource_id = aws_api_gateway_resource.hello_resource.id
  http_method             = aws_api_gateway_method.get_hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.hello.invoke_arn
}
 
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
 
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]
rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
}
