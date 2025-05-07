
Resource "aws_sns_topic" "image_topic" {
  Name = var.sns_topic_name
}

Output "sns_topic_arn" {
  Value = aws_sns_topic.image_topic.arn
}
