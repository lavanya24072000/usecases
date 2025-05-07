output “source_bucket” {
  Value = module.s3.source_bucket_name
}

Output “lambda_function_name” {
  Value = module.lambda.lambda_function_name
}


