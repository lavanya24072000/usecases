provider "aws" {
  region = var.region
}

# IAM Role for EC2 to access Secrets Manager
resource "aws_iam_role" "ec2_secrets_role" {
  name = "ec2_secrets_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "secrets_access_policy" {
  name = "secrets_policy"
  role = aws_iam_role.ec2_secrets_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = ["secretsmanager:GetSecretValue"],
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2_secrets_role.name
}

# Create Secret in Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "aurora-db-secret-first"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = var.db_username,
    password = var.db_password
  })
}

# Aurora Cluster and Instance
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  master_username         = var.db_username
  master_password         = var.db_password
  skip_final_snapshot     = true
  database_name           = "sampledb"
  vpc_security_group_ids  = [var.security_group_id]
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier              = "aurora-instance-1"
  cluster_identifier      = aws_rds_cluster.aurora.id
  instance_class          = "db.t3.medium"
  engine                  = aws_rds_cluster.aurora.engine
}

resource "aws_db_subnet_group" "default" {
  name       = "aurora-subnet-group"
  subnet_ids = [
    var.subnet_id_1,
    var.subnet_id_2
  ]
}

# EC2 Instance with App
resource "aws_instance" "app_ec2" {
  ami                         = "ami-0c7217cdde317cfec"n
  instance_type               = "t2.micro"
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = file("user_data.sh")

  tags = {
    Name = "AppEC2"
  }
}
