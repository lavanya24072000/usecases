variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_ids" {}
variable "vpc_id" {}

variable "public_key_path" {
  default = "/home/ubuntu/.ssh/id_rsa.pub"
}
