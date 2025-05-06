variable "aws_region" {
  type= string
  default = "eu-west-1"

}
variable "ports" {
  type= list(string)
  default = [22, 80, 8080]
}
