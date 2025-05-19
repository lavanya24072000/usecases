provider "aws" {
  region = var.aws_region
}
 
module "vpc" {
  source = "./modules/vpc"
}
 
module "ec2" {
  source         = "./modules/ec2"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.subnet_id
}
 
module "alb" {
  source            = "./modules/alb"
  vpc_id            = module.vpc.vpc_id
  subnet_id         = aws_subnet.public_a.id, aws_subnet.public_b.id]
  ec2_id            = module.ec2.ec2_id
  security_group_id = module.ec2.security_group_id
}
