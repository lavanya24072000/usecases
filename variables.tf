variable "lambda_zip_path" {}
variable "function_name" {}
variable "handler" {
  default = "lambda_function.lambda_handler"
}
variable "runtime" {
  default = "python3.8"
}
variable "environment_variables" {
  type    = map(string)
  default = {}
}
variable "role_arn" {}
variable "lambda_role_name" {}
variable "user_pool_name" {}
variable "app_client_name" {}
variable "domain_prefix" {}

variable "api_id" {
  description = "API Gateway ID for callback URL"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}
variable "lambda_function_arn" {}
