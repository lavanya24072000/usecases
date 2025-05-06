variable "aws_region" {
  default = "eu-west-1"

variable "instance_type" {
  default = "t2.medium"
}

variable "ports" {
  default = [22, 80, 8080]
}

variable "tags" {
  default = {
    Name        = "OpenProject-DevLake-Setup"
    Environment = "Dev"
  }
}
