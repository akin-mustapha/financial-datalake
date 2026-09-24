data "archive_file" "ingestion" {
  type             = "zip"
  source_file      = "${path.module}/../src/t212-data-ingestion.py"
  output_path      = "${path.module}/build/t212-data-ingestion.zip"
  output_file_mode = "0666"
}

data "archive_file" "transformation" {
  type = "zip"
  source_file = "${path.module}/../src/t212-data-transformation.py"
  output_path = "${path.module}/build/t212-data-transformation.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "ingestion" {
  function_name = "t212-data-ingestion"
  role          = aws_iam_role.lambda_ingestion.arn
  handler       = "ingestion.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.ingestion.output_path
  source_code_hash = data.archive_file.ingestion.output_base64sha256
}

resource "aws_lambda_function" "transformation" {
  function_name = "t212-data-transformation"
  role          = aws_iam_role.lambda_ingestion.arn
  handler = "transformation.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30
  memory_size   = 128

  filename         = data.archive_file.transformation.output_path
  source_code_hash = data.archive_file.transformation.output_base64sha256
}

resource "aws_lambda_function_event_invoke_config" "ingestion" {
  function_name = aws_lambda_function.ingestion.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.pipeline_alerts.arn
    }
  }
}

resource "aws_lambda_function_event_invoke_config" "transformation" {
  function_name = aws_lambda_function.transformation.function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.pipeline_alerts.arn
    }
  }
}
