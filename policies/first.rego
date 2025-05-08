package main
 
deny[msg] {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_s3_bucket"
  resource.change.after.acl == "public-read"
  msg := "S3 bucket is public!"
}
