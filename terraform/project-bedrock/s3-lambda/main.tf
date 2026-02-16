# Optional but strongly recommended: auto-zip your lambda.py every time it changes
# Remove if you prefer to manage lambda.zip manually
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda.py"          # ← adjust path if lambda.py is not in same folder
  output_path = "${path.module}/lambda.zip"
}

resource "aws_s3_bucket" "assets" {
  bucket = "bedrock-assets-${var.student_id}"

  tags = {
    Project = var.project
  }
}

# Optional: Enable versioning or other bucket settings if needed later
# versioning {
#   enabled = true
# }

resource "aws_iam_role" "lambda" {
  name = "bedrock-asset-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Optional: Add S3 read access if your Lambda needs to GetObject from the bucket
# resource "aws_iam_role_policy" "lambda_s3_read" {
#   name = "lambda-s3-read-policy"
#   role = aws_iam_role.lambda.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect   = "Allow"
#         Action   = ["s3:GetObject"]
#         Resource = "${aws_s3_bucket.assets.arn}/*"
#       }
#     ]
#   })
# }

resource "aws_lambda_function" "processor" {
  function_name = "bedrock-asset-processor"
  role          = aws_iam_role.lambda.arn
  handler       = "lambda.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.lambda_zip.output_path   # or "${path.module}/lambda.zip" if manual
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # detects code changes

  # timeout       = 30   # optional - increase if needed
  # memory_size   = 128  # optional
}

# ← This is the critical missing piece!
# Allows S3 to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.assets.arn
}

resource "aws_s3_bucket_notification" "trigger" {
  bucket = aws_s3_bucket.assets.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processor.arn
    events              = ["s3:ObjectCreated:*"]
    # id                = "object-created-trigger"   # optional - helps if you have multiple
  }

  # ← Prevents race condition: notification waits for permission to exist
  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

output "bucket_name" {
  value = aws_s3_bucket.assets.bucket
}