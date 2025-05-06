variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
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