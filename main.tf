provider "aws" {
  region = var.aws_region
}
 
resource "random_id" "bucket_id" {
  byte_length = 4
}
 
resource "aws_s3_bucket" "documents_bucket" {
  bucket = "semantic-s3-documents-${random_id.bucket_id.hex}"
}
 
resource "aws_db_subnet_group" "default" {
  name       = "pg-subnet-group"
  subnet_ids = "subnet-01224d04bf2330624" 
}
 
resource "aws_db_instance" "pg" {
  identifier          = "pgvector-instance"
  engine              = "postgres"
  instance_class      = "db.t3.micro"
  username            = "admin"
  password            = "admin1234"
  allocated_storage   = 20
  db_name             = "semanticdb"
  publicly_accessible = true
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.default.name
  vpc_security_group_ids = "sg-07d0781c1a4bd48db"
}
 
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-role001"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
role = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
 
resource "aws_lambda_function" "search_api" {
  function_name = "semantic-search-api"
  runtime       = "python3.11"
  handler       = "app.lambda_handler"
  role          = aws_iam_role.lambda_exec.arn
filename = "lambda_package.zip"
  timeout       = 30
 
  environment {
    variables = {
      DB_HOST = aws_db_instance.pg.address
      DB_NAME = "semanticdb"
      DB_USER = "admin"
      DB_PASS = "admin1234"
    }
  }
}
 
resource "aws_api_gateway_rest_api" "semantic_api" {
  name = "semantic-search-api"
}
 
resource "aws_api_gateway_resource" "search" {
rest_api_id = aws_api_gateway_rest_api.semantic_api.id
  parent_id   = aws_api_gateway_rest_api.semantic_api.root_resource_id
  path_part   = "search"
}
 
resource "aws_api_gateway_method" "search_method" {
rest_api_id = aws_api_gateway_rest_api.semantic_api.id
resource_id = aws_api_gateway_resource.search.id
  http_method   = "POST"
  authorization = "NONE"
}
 
resource "aws_api_gateway_integration" "lambda_integration" {
rest_api_id = aws_api_gateway_rest_api.semantic_api.id
resource_id = aws_api_gateway_resource.search.id
  http_method             = aws_api_gateway_method.search_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.search_api.invoke_arn
}
 
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_api.function_name
principal = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.semantic_api.execution_arn}/*/*"
}
 
