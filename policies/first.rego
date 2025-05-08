package terraform.deny
 
deny[msg] {
  some i
  input.resource_changes[i].type == "aws_s3_bucket"
  input.resource_changes[i].change.after.acl == "public-read"
  msg := "Public S3 buckets are not allowed"
}
