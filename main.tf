module "s3" {
  source              = "./modules/s3"
  source_bucket_name  = var.source_bucket_name
  dest_bucket_name    = var.dest_bucket_name
  tags                = var.tags
 
}
 
module "sns" {
  source           = "./modules/sns"
  topic_name       = var.sns_topic_name
  tags             = var.tags
  email            = var.email
}
 
module "iam" {
  source            = "./modules/iam"
  source_bucket_arn = module.s3.source_bucket_arn
  dest_bucket_arn   = module.s3.dest_bucket_arn
  sns_topic_arn     = module.sns.topic_arn
  lambda_role         = var.lambda_role
}
 
module "lambda" {
  source             = "./modules/lambda"
  function_name      = var.lambda_function_name
  role_arn           = module.iam.lambda_role_arn
  source_bucket_name = var.source_bucket_name
  dest_bucket_name   = var.dest_bucket_name
  sns_topic_arn      = module.sns.topic_arn
  resize_width       = var.resize_width
  tags               = var.tags
}