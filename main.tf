provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "semantic-search-documents-${random_id.suffix.hex}"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role-${random_id.suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Sid    = "",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Lambda Layers
resource "aws_lambda_layer_version" "pdf_layer" {
  layer_name          = "pdf-processing"
  s3_bucket           = "my-cognito-login-page"
  s3_key              = "layer1.zip"
  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_layer_version" "embedding_layer" {
  layer_name          = "embedding-tools"
  s3_bucket           = "my-cognito-login-page"
  s3_key              = "layer2.zip"
  compatible_runtimes = ["python3.8"]
}

resource "aws_lambda_layer_version" "db_layer" {
  layer_name          = "db-and-sdk"
  s3_bucket           = "my-cognito-login-page"
  s3_key              = "layer3.zip"
  compatible_runtimes = ["python3.8"]
}

# Lambda Function
resource "aws_lambda_function" "ingestion_function" {
  function_name = "document_ingestion"
  s3_bucket     = "my-cognito-login-page"
  s3_key        = "ingestion.zip"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30

  source_code_hash = filebase64sha256("${path.module}/lambda/ingestion.zip")

  layers = [
    aws_lambda_layer_version.pdf_layer.arn,
    aws_lambda_layer_version.embedding_layer.arn,
    aws_lambda_layer_version.db_layer.arn
  ]

  environment {
    variables = {
      BUCKET_NAME = "my-cognito-login-page"
      DB_HOST     = var.db_host
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
    }
  }
}

# RDS Cluster
resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier   = "aurora-cluster-${random_id.suffix.hex}"
  engine               = "aurora-postgresql"
  master_username      = var.db_user
  master_password      = var.db_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count               = 1
  identifier          = "aurora-instance-${count.index}-${random_id.suffix.hex}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.r5.large"
  engine              = "aurora-postgresql"
}
