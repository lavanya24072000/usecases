
variable "region" {{
  description = "AWS region"
}}

variable "db_username" {{
  description = "Database username"
}}

variable "db_password" {{
  description = "Database password"
}}

variable "key_name" {{
  description = "Key pair name for EC2 instance"
}}

variable "security_group_id" {{
  description = "ID of the existing security group in the correct VPC"
}}

variable "subnet_id_1" {{
  description = "First subnet ID for RDS (in one AZ)"
}}

variable "subnet_id_2" {{
  description = "Second subnet ID for RDS (in a different AZ)"
}}

variable "ec2_subnet_id" {{
  description = "Subnet ID for EC2 instance"
}}
