variable "name" {
  type        = string
  description = "Name of helm chart"
}

variable "namespace" {
  type        = string
  description = "Name of the namespace to install Helm Chart"
  default     = "default"
}

variable "create_namespace" {
  type        = bool
  description = "Boolean flag to create the namespace when creating the helm chart"
  default     = false
}

variable "repository" {
  type        = string
  description = "URL of Helm repository"
}

variable "chart" {
  type        = string
  description = "Name of the Helm chart"
}

variable "chart_version" {
  type        = string
  description = "Version of helm chart"
}

variable "cleanup_on_fail" {
  type        = bool
  description = "Cleanup chart resources if the deployment fail"
  default     = true
}

variable "atomic" {
  type        = bool
  description = "Rollback changes if anything goes wrong"
  default     = true
}

variable "values" {
  type        = any
  description = "Chart values"
  default     = null
}

variable "set" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))
  description = "Setting values within the helm chart"
  default     = []
}
