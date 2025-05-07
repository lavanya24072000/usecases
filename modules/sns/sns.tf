
resource "aws_sns_topic" "image_topic" {
  name = var.sns_topic_name
}

output "sns_topic_arn" {
  value = aws_sns_topic.image_topic.arn
}
