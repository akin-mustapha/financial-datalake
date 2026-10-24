output "secret_name" {
  description = "The name of the secret"
  value        = aws_secret_manager.this.name
}

output "secret_arn" {
  description = "The name of the secret"
  value        = aws_secret_manager.this.arn
}