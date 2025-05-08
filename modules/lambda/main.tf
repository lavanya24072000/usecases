/*data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/files"
  output_path = "${path.module}/lambda.zip"
} */
 
resource "aws_lambda_function" "image_resizer" {
  function_name    = var.function_name
  role             = var.role_arn
  runtime          = "nodejs18.x"
  handler          = "index.handler"
  filename         = "${path.module}/../../file/js/image_resizer.zip"
  source_code_hash = filebase64sha256("${path.module}/../../file/js/image_resizer.zip")
 
  environment {
    variables = {
      DEST_BUCKET    = var.dest_bucket_name
      SNS_TOPIC_ARN  = var.sns_topic_arn
      RESIZE_WIDTH   = var.resize_width
      RESIZED_BUCKET_NAME = var.dest_bucket_name
    }
  }
 
  tags = var.tags
}
 
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_resizer.arn
  principal = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.source_bucket_name}"
}
 
resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = var.source_bucket_name
 
  lambda_function {
    lambda_function_arn = aws_lambda_function.image_resizer.arn
    events              = ["s3:ObjectCreated:*"]
  }
 
  depends_on = [aws_lambda_permission.allow_s3]
}
 
