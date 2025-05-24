provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "semantic-search-documents"
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

resource "aws_lambda_function" "ingestion_function" {
  function_name = "document_ingestion"
  s3_bucket     = "my-cognito-login-page"
  s3_key        = "ingestion.zip"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30

  source_code_hash = filebase64sha256("${path.module}/lambda/ingestion.zip")

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

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier   = "aurora-cluster"
  engine               = "aurora-postgresql"
  master_username      = var.db_user
  master_password      = var.db_password
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count               = 1
  identifier          = "aurora-instance-${count.index}"
  cluster_identifier  = aws_rds_cluster.aurora_cluster.id
  instance_class      = "db.r5.large"
  engine              = "aurora-postgresql"
}
