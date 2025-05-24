variable "db_host" {
  type = string
  default= "first"
}

variable "db_name" {
  type = string
  default= "first"
}

variable "db_user" {
  type = string
  default= "first"
}

variable "db_password" {
  type = string
  default= "Prashola@2407"
}

variable "vpc_id" {
  type = string
  default= "vpc-06c1c352d16a03fe2"
}

variable "subnet_ids" {
  type = list(string)
  default= "subnet-029a8beb2b79e585"
}
