variable "ami_id" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_ids" {}
variable "vpc_id" {}

variable "public_key_path" {
  description = "Path to the SSH public key"
  type        = string
  default     = "./modules/ec2/id_rsa.pub"
}
