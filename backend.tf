terraform {
  backend "s3" {
    bucket         = "lavanya-bucket001"
    key            = "lambda/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    use_lockfile   = false
  }
}
