output "source_bucket" {
  value = module.s3.source_bucket_name
}

output "lambda_function_name" {
  value = module.lambda.lambda_function_name
}


