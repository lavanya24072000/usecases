variable "db_name" {
  type        = string
}
variable "db_username" {
  type        = string
}
variable "db_password" {
  type        = string
}

variable "private_subnet_id_1" {
  type        = string
}
variable "private_subnet_id_2" {
  default = "firstsecondthird"
  type        = string
}
