resource "aws_instance" "web_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  security_groups = [var.web_sg_id]
  
  user_data = file("scripts/userdata.sh")

  tags = {
    Name = "Web Server"
  }

  associate_public_ip_address = true
}
