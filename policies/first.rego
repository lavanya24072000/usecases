
package terraform.deny

deny[msg] {
  some i
  resource := input.resource_changes[i]
  resource.type == "aws_s3_bucket"
  resource.change.after.acl == "public-read"
  msg := "Public S3 buckets are not allowed"
}
