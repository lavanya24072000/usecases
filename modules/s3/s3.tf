resource "aws_s3_bucket" "source" {
  bucket = "lavanya-source-bucket"
}

resource "aws_s3_bucket" "destination" {
  bucket = "lavanya-destination-bucket"
}

output "source_bucket_arn" {
  value = aws_s3_bucket.source.arn
}

output "destination_bucket_arn" {
  value = aws_s3_bucket.destination.arn
}

output "source_bucket_name" {
  value = aws_s3_bucket.source.id
}

output "destination_bucket_name" {
  value = aws_s3_bucket.destination.id
}



