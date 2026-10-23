resource "aws_scheduler_schedule" "this" {
  name       = var.name
  group_name = var.group_name

  flexible_time_window {
    mode = var.flexible_time_window
  }

  schedule_expression          = var.schedule_expression
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = var.target_arn
    role_arn = var.target_role_arn
    input    = jsonencode({ run_type = var.target_input })

    retry_policy {
      maximum_event_age_in_seconds = 86400
      maximum_retry_attempts       = 0
    }
  }
}
