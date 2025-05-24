output "bucket_name" {
  value = aws_s3_bucket.documents_bucket.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.ingestion_function.function_name
}

output "db_endpoint" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}
