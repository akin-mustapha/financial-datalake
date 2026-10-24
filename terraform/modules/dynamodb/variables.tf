variable "table_name" {
  description = "Dynamo db table name"
  type = string
}

variable "billing_mode" {
  description = "Dynamo DB table billing_modoe"
  type = string
  default = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Dynamo DB table hash_key"
  type = string
}

variable "attributes" {
  description = "Dynamo DB table attributes"
  type = list(object({
    name = string
    type = string
  }))
}