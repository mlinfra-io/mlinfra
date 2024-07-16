variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC provider to use for authentication"
  default     = null
}

variable "oidc_provider" {
  type        = string
  description = "The OIDC provider to use for authentication"
  default     = null
}

variable "availability_zones" {
  type = list(string)
}

variable "remote_tracking" {
  type = bool
}

variable "milvus_storage_bucket" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "service_account_namespace" {
  type        = string
  description = "The namespace where the service account would be installed"
  default     = ""
}

variable "service_account_name" {
  type        = string
  description = "The name of the service account to use for "
  default     = "-sa"
}

variable "region" {
  type = string
}

variable "milvus_chart_version" {
  type    = string
  default = "4.0.31"
}
