provider "aws" {
  region = "us-east-1"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

resource "aws_s3_bucket" "documents" {
  bucket = "semantic-search-docs-${random_id.bucket_id.hex}"
}
 
data "archive_file" "ingestion_zip" {
  type        = "zip"
  source_dir  = "${path.module}/ingestion_lambda"
  output_path = "${path.module}/ingestion.zip"
}

data "archive_file" "search_zip" {
  type        = "zip"
  source_dir  = "${path.module}/search_lambda"
  output_path = "${path.module}/search.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "ingestion" {
  function_name = "semantic_ingestion"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = data.archive_file.ingestion_zip.output_path

  environment {
    variables = {
      OPENAI_KEY = var.openai_api_key
      PG_HOST    = var.pg_host
      PG_USER    = var.pg_user
      PG_PASS    = var.pg_pass
      PG_DB      = var.pg_db
    }
  }
}

resource "aws_lambda_function" "search" {
  function_name = "semantic_search"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"
  role          = aws_iam_role.lambda_exec_role.arn
  filename      = data.archive_file.search_zip.output_path

  environment {
    variables = {
      OPENAI_KEY = var.openai_api_key
      PG_HOST    = var.pg_host
      PG_USER    = var.pg_user
      PG_PASS    = var.pg_pass
      PG_DB      = var.pg_db
    }
  }
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.documents.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.ingestion.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingestion.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.documents.arn
}

resource "aws_apigatewayv2_api" "search_api" {
  name          = "semantic-search-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id             = aws_apigatewayv2_api.search_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.search.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "search_route" {
  api_id    = aws_apigatewayv2_api.search_api.id
  route_key = "POST /search"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.search_api.id
  name        = "$default"
  auto_deploy = true
}
 
