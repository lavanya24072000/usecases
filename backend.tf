terraform {
  backend "s3" {
    bucket         = "pavithra-bucket001"
    key            = "uc5/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = true
  }
}