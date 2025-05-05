
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
module "vpc" {
  source = "./modules/vpc"
}

# Create web servers in public subnets
module "web_server_1" {
  source             = "./modules/web_server"
  ami_id             = "ami-058a8a5ab36292159"  # Replace with your AMI
  instance_type      = "t2.medium"
  public_subnet_id   = module.vpc.public_subnet_1_id
  web_sg_id          = module.vpc.web_security_group_id
}

module "web_server_2" {
  source             = "./modules/web_server"
  ami_id             = "ami-058a8a5ab36292159  # Replace with your AMI
  instance_type      = "t2.micro"
  public_subnet_id   = module.vpc.public_subnet_2_id
  web_sg_id          = module.vpc.web_security_group_id
}

# Create RDS MySQL instance in private subnets
module "rds" {
  source            = "./modules/rds"
  db_username       = "admin"
  db_password       = "prashola"
  db_name           = "mydb"
  private_subnet_id = module.vpc.private_subnet_1_id
}
