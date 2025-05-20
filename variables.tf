variable "region"           { default = "us-east-1" }
variable "vpc_id"           {}
variable "subnet_id"        {}
variable "security_group_id" {}
variable "db_username"      { type = string }
variable "db_password"      { type = string }
variable "key_name"         {}  #
