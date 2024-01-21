variable "secret_name" {
  type        = string
  default     = "application-secret"
  description = "Name by which the secret has to be persisted in the "
}

variable "secret_value" {
  type        = map(string)
  description = "Secret value to be stored in the secrets manager"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be added to the secret manager to identify the application / resources using it"
  default = {
    name = "secrets-manager"
  }
}
