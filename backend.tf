terraform {
  backend "s3" {
    bucket         = "service-catlog-templates-bucket"
    key            = "usecase17/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    use_lockfile   = false
  }
}
