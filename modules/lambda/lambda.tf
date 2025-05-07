Data “archive_file” “lambda_zip” {
  Type        = “zip”
  Source_dir  = “${path.module}/lambda_src”
  Output_path = “${path.module}/lambda.zip”
}

Resource “aws_lambda_function” “resize_image” {
  Filename         = data.archive_file.lambda_zip.output_path
  Function_name    = “resize-image”
  Role             = var.lambda_role_arn
  Handler          = “index.lambda_handler”
  Runtime          = “python3.9”
  Source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  Environment {
    Variables = {
      DEST_BUCKET   = var.destination_bucket
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}

Resource “aws_lambda_permission” “s3_invoke” {
  Statement_id  = “AllowExecutionFromS3”
  Action        = “lambda:InvokeFunction”
  Function_name = aws_lambda_function.resize_image.arn
  Principal     = “s3.amazonaws.com”
  Source_arn    = “arn:aws:s3:::${var.source_bucket}”
}

Resource “aws_s3_bucket_notification” “trigger_lambda” {
  Bucket = var.source_bucket

  Lambda_function {
    Lambda_function_arn = aws_lambda_function.resize_image.arn
    Events              = [“s3:ObjectCreated:*”]
  }

  Depends_on = [aws_lambda_permission.s3_invoke]
}

Output “lambda_function_name” {
  Value = aws_lambda_function.resize_image.function_name
}
