variable "region"  {
   default = "us-east-1" 
}
variable "vpc_id"           {
   type = string 
   default = "vpc-06c1c352d16a03fe2"
}
variable "subnet_id"        {
   type = string 
   default = "subnet-029a8beb2b79e585c"
}
variable "security_group_id" {
   type = string 
   default = "sg-0465db0ccfd942129"
}
variable "db_username"      {
   type = string 
   default = "lavanya"
}
variable "db_password"      { 
   type = string 
   default = "Lavanya@2407"
}
variable "key_name"         {
   type = string 
   default = "first"
}  
