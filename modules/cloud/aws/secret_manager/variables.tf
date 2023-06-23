variable "secret_name" {
  type    = string
  default = "awesome-secret"
}

variable "json_secret" {
  type    = bool
  default = false
}

variable "secret_value" {
  type = string
}
