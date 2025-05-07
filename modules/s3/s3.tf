Resource “aws_s3_bucket” “source” {
  Bucket = var.source_bucket_name
}

Resource “aws_s3_bucket” “destination” {
  Bucket = var.destination_bucket_name
}

Output “source_bucket_arn” {
  Value = aws_s3_bucket.source.arn
}

Output “destination_bucket_arn” {
  Value = aws_s3_bucket.destination.arn
}

Output “source_bucket_name” {
  Value = aws_s3_bucket.source.id
}




