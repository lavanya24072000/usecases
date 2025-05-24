provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "documents_bucket" {
  bucket = "semantic-search-documents"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Sid    = "",
      Principal = {
        Service = "lambda.amazonaws.com",
      },
    }],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}


resource "aws_lambda_function" "ingestion_function" {
  function_name = "document_ingestion"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  filename      = "${path.module}/lambda/ingestion.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda/ingestion.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.documents_bucket.bucket
      DB_HOST     = var.db_host
      DB_NAME     = var.db_name
      DB_USER     = var.db_user
      DB_PASSWORD = var.db_password
    }
  }
}


resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "aurora-cluster"
  engine             = "aurora-postgresql"
  master_username    = var.db_user
  master_password    = var.db_password
  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  count              = 1
  identifier         = "aurora-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora_cluster.id
  instance_class     = "db.r5.large"
  engine             = "aurora-postgresql"
}
