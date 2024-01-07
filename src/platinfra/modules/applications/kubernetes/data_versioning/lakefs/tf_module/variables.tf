variable "vpc_id" {
  type = string
}

variable "vpc_cidr_block" {
  type    = string
  default = null
}

variable "db_subnet_group_name" {
  type    = string
  default = null
}

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

variable "service_account_namespace" {
  type        = string
  description = "The namespace where the service account would be installed"
  default     = "lakefs"
}

variable "service_account_name" {
  type        = string
  description = "The name of the service account to use for lakeFS"
  default     = "lakefs-sa"
}

variable "remote_tracking" {
  type        = bool
  description = "This variable tracks if the LakeFS is deployed with an external metadata tracker and blob storage"
  default     = false
}

variable "lakefs_data_bucket_name" {
  type        = string
  description = ""
  default     = "lakefs-data-bucket"
}

variable "rds_instance_class" {
  type        = string
  description = ""
  default     = "db.t4g.medium"
}

variable "lakefs_chart_version" {
  type        = string
  description = "LakeFS Chart version. See here for more details; https://artifacthub.io/packages/helm/lakefs/lakefs"
  default     = "1.0.8"
}

variable "dynamodb_table_name" {
  type    = string
  default = "kvstore"
}

variable "database_type" {
  type    = string
  default = null

  validation {
    condition     = (var.database_type == "dynamodb" || var.database_type == "postgres" || var.database_type == null)
    error_message = "database_type must be either 'dynamodb' or 'postgres'"
  }
}

variable "skip_final_snapshot" {
  type        = bool
  description = "If set to true, no final snapshot of the RDS instance will be created"
  default     = false
}

variable "lakefs_secret" {
  type        = string
  description = "The name of the secret containing the lakeFS credentials"
  default     = "lakefs-db-auth"
}

variable "resources" {
  type        = map(any)
  description = "The resources to allocate to each lakeFS pod"
  default = {
    requests = {
      cpu    = "100m"
      memory = "128Mi"
    }
    limits = {
      cpu    = "200m"
      memory = "256Mi"
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
  description = "The nodeSelector to schedule lakeFS pods on specific nodes"
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
  description = "The tolerations to schedule lakeFS pods on specific nodes"
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
  description = "The affinity to schedule lakeFS pods on specific nodes"
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

variable "tags" {
  type = map(string)
  default = {
    name = "lakefs-on-k8s"
  }
}
