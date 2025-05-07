Module “s3” {
  Source                = “./modules/s3”
  Source_bucket_name    = var.source_bucket_name
  Destination_bucket_name = var.destination_bucket_name
}

Module “sns” {
  Source          = “./modules/sns”
  Sns_topic_name  = var.sns_topic_name
}

Module “iam” {
  Source                 = “./modules/iam”
  Source_bucket_arn      = module.s3.source_bucket_arn
  Destination_bucket_arn = module.s3.destination_bucket_arn
  Sns_topic_arn          = module.sns.sns_topic_arn
}

Module “lambda” {
  Source                = “./modules/lambda”
  Lambda_role_arn       = module.iam.lambda_role_arn
  Source_bucket         = var.source_bucket_name
  Destination_bucket    = var.destination_bucket_name
  Sns_topic_arn         = module.sns.sns_topic_arn
}
