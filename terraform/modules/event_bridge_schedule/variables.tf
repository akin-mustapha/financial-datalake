variable "name" {
  type = string
}

variable "group_name" {
  type = string
  default = "default"
}

variable "flexible_time_window" {
  type = string
}

variable "schedule_expression" {
  type = string
}

variable "schedule_expression_timezone" {
  type = string
}

variable "target_arn" {
  type = string
}

variable "target_role_arn" {
  type = string
}

variable "target_input" {
  type = string
}