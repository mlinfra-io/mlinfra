variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC provider to use for authentication"
}

variable "oidc_provider" {
  type        = string
  description = "The OIDC provider to use for authentication"
}

variable "remote_tracking" {
  type    = bool
  default = false
}

variable "milvus_storage_bucket" {
  type    = string
  default = "milvus-storage-"
}

variable "tags" {
  type = map(string)
  default = {
    "vector_database" = "milvus"
  }
}

variable "service_account_namespace" {
  type        = string
  description = "The namespace where the service account would be installed"
  default     = "milvus"
}

variable "service_account_name" {
  type        = string
  description = "The name of the service account to use for Milvus"
  default     = "milvus-sa"
}

variable "milvus_chart_version" {
  type    = string
  default = "4.2.11"
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
      cpu    = "500m"
      memory = "4096Mi"
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

variable "nodeSelector" {
  type        = map(any)
  description = "The nodeSelector to schedule mlflow pods on specific nodes"
  validation {
    condition = (
      alltrue([
        for selector in keys(var.nodeSelector) :
        can(selector) && can(var.nodeSelector[selector]) && var.nodeSelector[selector] != ""
      ])
    )
    error_message = "Each nodeSelector must have a key and a non-empty value"
  }
  default = {
    "nodegroup_type" = "operations"
  }
}

variable "tolerations" {
  type        = list(any)
  description = "The tolerations to schedule mlflow pods on specific nodes"
  validation {
    condition = (
      alltrue([
        for toleration in var.tolerations :
        can(toleration.key) &&
        contains(["Equal", "Exists"], toleration.operator) &&
        can(toleration.value) &&
        contains(["NoSchedule", "PreferNoSchedule", "NoExecute"], toleration.effect)
      ])
    )
    error_message = "Each toleration must have operator set to 'Equal' or 'Exists' and effect set to 'NoSchedule', 'PreferNoSchedule' or 'NoExecute' along with key and value"
  }
  default = [{
    key      = "nodegroup_type"
    operator = "Equal"
    value    = "operations"
    effect   = "NoSchedule"
  }]
}

variable "affinity" {
  type        = map(any)
  description = "The affinity to schedule mlflow pods on specific nodes"
  validation {
    condition = (
      alltrue([
        for affinity in var.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms :
        alltrue([
          for expression in affinity.matchExpressions :
          can(expression.key) &&
          contains(["In", "NotIn", "Exists", "DoesNotExist", "Gt", "Lt"], expression.operator) &&
          can(expression.values)
        ])
      ])
    )
    error_message = "Each matchExpression must have operator set to 'In', 'NotIn', 'Exists', 'DoesNotExist', 'Gt', 'Lt' along with key and values"
  }
  default = {
    "nodeAffinity" = {
      "requiredDuringSchedulingIgnoredDuringExecution" = {
        "nodeSelectorTerms" = [{
          "matchExpressions" = [{
            key      = "nodegroup_type"
            operator = "In"
            values   = ["operations"]
          }]
        }]
      }
    }
  }
}
