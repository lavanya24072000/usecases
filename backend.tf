terraform {
  backend "s3" {
    bucket         = "demostore001"
    key            = "uc5/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    use_lockfile   = true
  }
}
