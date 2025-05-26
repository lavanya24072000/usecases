output "s3_bucket_name" {
  value = aws_s3_bucket.documents_bucket.bucket
}
 
output "db_address" {
  value = aws_db_instance.pg.address
}
 
output "lambda_function_name" {
  value = aws_lambda_function.search_api.function_name
}
 
output "api_gateway_url" {
  value = "${aws_api_gateway_rest_api.semantic_api.execution_arn}/search"
}
 
