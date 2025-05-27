
variable "template_url" {
  description = "URL of the CloudFormation template"
  type        = string
}

variable "launch_role_arn" {
  description = "ARN of the IAM role to be used for launching the product"
  type        = string
}

variable "user_arn" {
  description = "ARN of the IAM user to be granted access to the portfolio"
  type        = string
}
