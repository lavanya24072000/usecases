provider "aws" {
  region = var.aws_region
}
# Get latest Amazon Linux 2 AMI
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "OpenProject-VPC"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
  tags = {
    Name = "Public-Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group with dynamic block
resource "aws_security_group" "instance_sg" {
  name   = "instance-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2-SG"
  }
}

# ALB
resource "aws_lb" "app_lb" {
  name               = "openproject-devlake-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.instance_sg.id]
  subnets            = [aws_subnet.public.id]
}

# ALB Target Groups
resource "aws_lb_target_group" "openproject_tg" {
  name     = "openproject-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "devlake_tg" {
  name     = "devlake-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

# ALB Listener & Rules
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "This is default page"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "openproject_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.openproject_tg.arn
  }

  condition {
    path_pattern {
      values = ["/login*"]
    }
  }
}

resource "aws_lb_listener_rule" "devlake_rule" {
  listener_arn = aws_lb_listener.listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.devlake_tg.arn
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}

# EC2 Instance - OpenProject
resource "aws_instance" "openproject" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 openproject/community:latest
              EOF

  tags = merge(var.tags, {
    Name = "${lookup(var.tags, "Name", "default")}-OpenProject"
  })
}

# EC2 Instance - DevLake
resource "aws_instance" "devlake" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.instance_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              usermod -a -G docker ec2-user
              docker run -d -p 80:80 apache/devlake:latest
              EOF

  tags = merge(var.tags, {
    Name ="${lookup(var.tags, "Name", "default")}-DevLake"
  })
}

# Register Targets
resource "aws_lb_target_group_attachment" "openproject_attachment" {
  target_group_arn = aws_lb_target_group.openproject_tg.arn
  target_id        = aws_instance.openproject.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "devlake_attachment" {
  target_group_arn = aws_lb_target_group.devlake_tg.arn
  target_id        = aws_instance.devlake.id
  port             = 80
}
