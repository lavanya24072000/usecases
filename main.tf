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
  ami_id             = var.ami_id  # Replace with your AMI
  instance_type      = var.instance_type
  public_subnet_id   = module.vpc.public_subnet_1_id
  web_sg_id          = module.vpc.web_security_group_id
}

module "web_server_2" {
  source             = "./modules/web_server"
  ami_id             = var.ami_id  # Replace with your AMI
  instance_type      = var.instance_type
  public_subnet_id   = module.vpc.public_subnet_2_id
  web_sg_id          = module.vpc.web_security_group_id
}

# Create RDS MySQL instance in private subnets
module "rds" {
  source            = "./modules/rds"
  db_username       = var.db_username
  db_password       = var.db_password
  db_name           = var.db_name
  private_subnet_id_1= module.vpc.private_subnet_1_id
  private_subnet_id_2= module.vpc.private_subnet_2_id
  
}
