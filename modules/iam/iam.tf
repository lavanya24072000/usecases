
Resource "aws_iam_role" "lambda_exec" {
  Name = "lambda_exec_role"
  Assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

Resource "aws_iam_role_policy" "lambda_policy" {
  Name = "lambda_policy"
  Role = aws_iam_role.lambda_exec.id
  Policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Effect   = "Allow",
        Resource = ["${var.source_bucket_arn}/*", "${var.destination_bucket_arn}/*"]
      },
      {
        Action = ["sns:Publish"],
        Effect = "Allow",
        Resource = var.sns_topic_arn
      },
      {
        Action = ["logs:*"],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

Output "lambda_role_arn" {
  Value = aws_iam_role.lambda_exec.arn
}
