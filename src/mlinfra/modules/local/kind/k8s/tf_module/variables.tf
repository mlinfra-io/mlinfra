variable "cluster_name" {
  type        = string
  description = "Name of the local KinD cluster"
  default     = "kind-cluster"
}

variable "node_image" {
  type        = map(any)
  description = "Sets Kubernetes image version for the KinD cluster"
  default = {
    "1.27" = "kindest/node:v1.27.11"
    "1.28" = "kindest/node:v1.28.7"
    "1.29" = "kindest/node:v1.29.2"
    "1.30" = "kindest/node:v1.30.0"
  }
}

variable "k8s_version" {
  type        = string
  description = "Defines kubernetes version for the KinD cluster"
}

variable "wait_for_control_plane" {
  type        = bool
  description = "Whether to wait for control plane to be available before creating dataplane"
}

variable "kubeconfig_path" {
  type        = string
  description = "Path of kubeconfig after getting created"
  default     = null
}
