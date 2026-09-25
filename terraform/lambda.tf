locals {
  pipeline_stages = toset(["ingestion", "transformation", "processing"])
}

data "archive_file" "pipeline" {
  for_each         = local.pipeline_stages
  type             = "zip"
  source_file      = "${path.module}/../src/pipeline/t212-data-${each.key}.py"
  output_path      = "${path.module}/build/t212-data-${each.key}.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "pipeline" {
  for_each      = local.pipeline_stages
  function_name = "t212-data-${each.key}"
  role          = aws_iam_role.lambda_pipeline.arn
  
  # Handler matches single-file zip name: t212-data-<stage>.lambda_handler
  handler       = "t212-data-${each.key}.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512

  filename         = data.archive_file.pipeline[each.key].output_path
  source_code_hash = data.archive_file.pipeline[each.key].output_base64sha256

  layers = [
    "arn:aws:lambda:${var.aws_region}:336392948345:layer:AWSSDKPandas-Python312:13"
  ]

  depends_on = [
    aws_iam_role_policy.lambda_pipeline
  ]
}

resource "aws_lambda_function_event_invoke_config" "pipeline" {
  for_each      = local.pipeline_stages
  function_name = aws_lambda_function.pipeline[each.key].function_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.pipeline_alerts.arn
    }
  }
}