variable "milvus_chart_version" {
  type        = string
  description = "Version of the Milvus Helm chart to use"
  default     = "4.2.12"
}

variable "resources" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  description = "Resource requests and limits for Milvus pods"
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "500m"
      memory = "512Mi"
    }
  }
}

variable "milvus_endpoint" {
  type    = string
  default = "milvus-attu.localhost"
}
