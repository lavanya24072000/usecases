
provider "aws" {
  region = var.aws_region
}

resource "aws_cloudtrail" "trail" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  cloud_watch_logs_group_arn  = aws_cloudwatch_log_group.cloudtrail_log_group.arn
  cloud_watch_logs_role_arn   = aws_iam_role.cloudtrail_role.arn
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = var.cloudtrail_bucket_name
}

resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name = var.cloudwatch_log_group_name
}

resource "aws_iam_role" "cloudtrail_role" {
  name = var.cloudtrail_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail_policy_attachment" {
  role       = aws_iam_role.cloudtrail_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_cloudwatch_log_metric_filter" "console_login_filter" {
  name           = "ConsoleLoginFilter"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{ ($.eventName = \"ConsoleLogin\") && ($.responseElements.ConsoleLogin = \"Success\") }"

  metric_transformation {
    name      = "SuccessfulConsoleLogin"
    namespace = "SecurityMetrics"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "console_login_alarm" {
  alarm_name          = var.cloudwatch_alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.console_login_filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.console_login_filter.metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_actions       = [aws_sns_topic.console_login_topic.arn]
}

resource "aws_sns_topic" "console_login_topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.console_login_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
