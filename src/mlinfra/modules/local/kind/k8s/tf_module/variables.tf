variable "cluster_name" {
  type        = string
  description = "Name of the local KinD cluster"
  default     = "kind-cluster"
}

variable "k8s_version" {
  type        = string
  description = "Defines kubernetes version for the KinD cluster"
  default     = "1.30"
}

variable "wait_for_control_plane" {
  type        = bool
  description = "Whether to wait for control plane to be available before creating dataplane"
  default     = false
}
