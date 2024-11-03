variable "mlflow_chart_version" {
  type        = string
  description = "mlflow Chart version."
  default     = "2.0.5"
}

variable "resources" {
  type        = map(any)
  description = "The resources to allocate to each mlflow pod"
  default = {
    requests = {
      cpu    = "100m"
      memory = "1024Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "2048Mi"
    }
  }
  validation {
    condition = (
      alltrue([
        for resource in keys(var.resources) :
        can(resource) && can(var.resources[resource]) && var.resources[resource] != "" &&
        contains(["requests", "limits"], resource) &&
        alltrue([
          for subresource in keys(var.resources[resource]) :
          can(subresource) && can(var.resources[resource][subresource]) && var.resources[resource][subresource] != "" &&
          contains(["cpu", "memory"], subresource) &&
          (subresource == "cpu" ? can(regex("^[0-9]+m?$", var.resources[resource][subresource])) : true) &&
          (subresource == "memory" ? can(regex("^[0-9]+(Mi|Mb|Gi|Gb)?$", var.resources[resource][subresource])) : true)
        ])
      ])
    )
    error_message = "Each resource must have 'requests' or 'limits' with 'cpu' and 'memory' along with their values. CPU should be in the format '100m' or '1' and memory should be in the format '128Mi' or '1Gi'"
  }
}

variable "mlflow_endpoint" {
  type    = string
  default = "mlflow.localhost"
}
