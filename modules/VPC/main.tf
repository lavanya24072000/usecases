provider "aws" {
  region = var.aws_region
}
 
resource "aws_vpc" "main" {
cidr_block = var.vpc_cidr    
  enable_dns_support   = true
  enable_dns_hostnames = true
 
  tags = {
    Name = "focalboard-vpc"
  }
}
 
resource "aws_subnet" "public" {
vpc_id = aws_vpc.main.id
cidr_block = var.subnet_cidr  
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
 
  tags = {
    Name = "focalboard-public-subnet"
  }
}
 
data "aws_availability_zones" "available" {}
 
resource "aws_internet_gateway" "igw" {
vpc_id = aws_vpc.main.id
 
  tags = {
    Name = "focalboard-igw"
  }
}
 
resource "aws_route_table" "public" {
vpc_id = aws_vpc.main.id
 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
 
  tags = {
    Name = "focalboard-public-rt"
  }
}
 
resource "aws_route_table_association" "public" {
subnet_id = aws_subnet.public.id
route_table_id = aws_route_table.public.id
}
 
