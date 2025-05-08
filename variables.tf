variable "source_bucket_name" {
  default = "lavanya-source-bucket"
}

variable "destination_bucket_name" {
  default = "lavanya-destination-bucket"
}

variable "sns_topic_name" {
  default = "image-resize-topic"
}
variable "source_bucket_arn" {
  description = "The ARN of the source S3 bucket"
  type        = string
}

