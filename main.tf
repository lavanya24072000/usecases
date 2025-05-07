module "s3" {
  source                = "./modules/s3"
  Source_bucket_name    = var.source_bucket_name
  Destination_bucket_name = var.destination_bucket_name
}

module "sns" {
  source          = "./modules/sns"
  sns_topic_name  = var.sns_topic_name
}

module "iam" {
  source                 = "./modules/iam"
  Source_bucket_arn      = module.s3.source_bucket_arn
  Destination_bucket_arn = module.s3.destination_bucket_arn
  Sns_topic_arn          = module.sns.sns_topic_arn
}

module "lambda" {
  source                = "./modules/lambda"
  Lambda_role_arn       = module.iam.lambda_role_arn
  Source_bucket         = var.source_bucket_name
  Destination_bucket    = var.destination_bucket_name
  Sns_topic_arn         = module.sns.sns_topic_arn
}
