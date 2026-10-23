
variable "function_name" {
  type = string
}

variable "source_file" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}

variable "timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 128
}
