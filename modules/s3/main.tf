resource "aws_s3_bucket" "source" {
  bucket = var.source_bucket_name
  tags   = var.tags
 
  versioning {
    enabled = true
  }
 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
 
resource "aws_s3_bucket" "destination" {
  bucket = var.dest_bucket_name
  tags   = var.tags
 
  versioning {
    enabled = true
  }
 
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
 