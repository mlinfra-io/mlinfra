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
  description = ""
  default     = {}
}

variable "nodeSelector" {
  type        = map(any)
  description = "The nodeSelector to schedule lakeFS pods on specific nodes"
  default = {
    "nodegroup_type" = "operations"
  }
}

variable "tolerations" {
  type        = list(any)
  description = "The tolerations to schedule lakeFS pods on specific nodes"
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

# TODO: manage lakefs taints and tolerations here

variable "tags" {
  type = map(string)
  default = {
    name = "lakefs-on-k8s"
  }
}
