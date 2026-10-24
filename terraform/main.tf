provider "aws" {
  region = var.aws_region
}

// Storage

module "s3" {
  source      = "./modules/s3"
  bucket_name = "financial-dataflow"
}

// Secret Manager

module "t212_secret" {
  source      = "./modules/secret_manager"
  secret_name = "prod/financial-dataflow/trading212"

}

// Schedule

module "europe_open" {
  source     = "./modules/event_bridge_schedule"
  name       = "financial-dataflow-europe-open"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(20 8 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"

  target_arn      = aws_lambda_function.pipeline["ingestion"].arn
  target_role_arn = aws_iam_role.financial_dataflow.arn
  target_input    = "europe-open" 
}

module "midday" {
  source     = "./modules/event_bridge_schedule"
  name       = "financial-dataflow-midday"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(20 13 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"

  target_arn      = aws_lambda_function.pipeline["ingestion"].arn
  target_role_arn = aws_iam_role.financial_dataflow.arn
  target_input    = "midday" 
}

module "us_close" {
  source     = "./modules/event_bridge_schedule"
  name       = "financial-dataflow-us-close"
  group_name = "default"

  flexible_time_window = "OFF"

  schedule_expression          = "cron(30 16 * * ? *)"
  schedule_expression_timezone = "Europe/Dublin"

  target_arn      = aws_lambda_function.pipeline["ingestion"].arn
  target_role_arn = aws_iam_role.financial_dataflow.arn
  target_input    = "us-close" 
}

// Compute resources

module "ingestion_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-ingestion"
  source_file = "${path.root}/../src/pipeline/t212-data-ingestion.py"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-ingestion.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}

module "transformation_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-transformation"
  source_file = "${path.root}/../src/pipeline/t212-data-transformation.py"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-transformation.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}

module "processing_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-processing"
  source_file = "${path.root}/../src/pipeline/t212-data-processing.py"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-processing.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}

module "dca_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-processing"
  source_file = "${path.root}/../src/application/t212-dca.py"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-processing.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}

// Database

module "trade_log" {
  source       = "./modules/dynamodb"
  table_name   = "trade_log"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "trade_id"
  attributes   = [
    {
      name = "trade_id"
      type = "S"
    }
  ]
}

// Monitoring

module "ingestion-errors" {
  source              = "./modules/cloud_watch_alarm"
  alarm_name          = "financial-dataflow-ingestion-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Fires when financial-dataflow-ingestion has any invocation errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.pipeline["ingestion"].function_name
  }

  alarm_actions = [aws_sns_topic.pipeline_alerts.arn]
}