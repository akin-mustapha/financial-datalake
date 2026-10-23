
data "archive_file" "this" {
  type             = "zip"
  source_file      = var.source_file
  output_path      = "${path.root}/build/${var.function_name}.zip"
  output_file_mode = "0644"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.lambda_role_arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.this.output_path
  source_code_hash = data.archive_file.this.output_base64sha256

  timeout       = var.timeout
  memory_size   = var.memory_size
}