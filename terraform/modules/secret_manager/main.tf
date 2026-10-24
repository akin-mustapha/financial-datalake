resource "aws_secretsmanager_secret" "this" {
  name = var.secret_name
}


# resource "aws_secretsmanager_secret" "t212_dca_automation" {
#   name = "prod/financial/t212-dca-automation"
# }
