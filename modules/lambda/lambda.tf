data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "resize_image" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "resize-image"
  role             = var.lambda_role_arn
  handler          = "index.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      DEST_BUCKET   = var.destination_bucket
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.resize_image.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_bucket}"
}

resource "aws_s3_bucket_notification" "trigger_lambda" {
  bucket = var.source_bucket

  lambda_function {
    lambda_function_arn = aws_lambda_function.resize_image.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

output "lambda_function_name" {
  value = aws_lambda_function.resize_image.function_name
}
