variable "secret_name" {
  type    = string
  default = "awesome-secret"
}

variable "secret_value" {
  type = map(string)
}
