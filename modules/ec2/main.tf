resource "aws_security_group" "focal_sg" {
  name        = "focalboard-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = var.vpc_id
 
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "focal_ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
vpc_security_group_ids = [aws_security_group.focal_sg.id]
  associate_public_ip_address = true
  key_name               = var.key_name
 
user_data = file("${path.module}/../../user_data.sh")
 
  tags = { Name = "focalboard-instance" }
}
