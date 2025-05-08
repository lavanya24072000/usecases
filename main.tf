provider "aws" {
  region = "eu-west-1"
}

module "s3" {
  source                = "./modules/s3"
}

module "sns" {
  source          = "./modules/sns"
  sns_topic_name  = var.sns_topic_name
}

module "iam" {
  source                 = "./modules/iam"
  source_bucket_arn      = module.s3.source_bucket_arn
  destination_bucket_arn = module.s3.destination_bucket_arn
  sns_topic_arn          = module.sns.sns_topic_arn
}

module "lambda" {
  source                = "./modules/lambda"
  lambda_role_arn       = module.iam.lambda_role_arn
  source_bucket         = module.source_bucket_name
  destination_bucket    = module.destination_bucket_name
  sns_topic_arn         = module.sns.sns_topic_arn
}
