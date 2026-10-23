provider "aws" {
  region = var.aws_region
}

module "s3" {
  source = "./modules/s3"
  bucket_name = "financial-dataflow"
}

// Compute resources

module "ingestion_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-ingestion"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-ingestion.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}


module "transformation_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-transformation"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-transformation.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}


module "processing_lambda" {
  source = "./modules/lambda_function"

  function_name = "portfolio-processing"
  lambda_role_arn = aws_iam_role.lambda_execution_role.arn
  handler       = "t212-data-processing.lambda_handler"
  runtime       = "python3.12"
  timeout       = 300
  memory_size   = 512
}
