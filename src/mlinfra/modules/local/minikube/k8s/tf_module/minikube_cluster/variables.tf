variable "driver" {
  type        = string
  description = "The driver to be used for the Minikube cluster"
  default     = "docker"
}

variable "cluster_name" {
  type        = string
  description = "Name of the local minikube cluster"
  default     = "minikube-cluster"
}

variable "k8s_version" {
  type        = string
  description = "Defines kubernetes version for the minikube cluster"
  default     = "1.30"
}

variable "nodes" {
  type        = number
  description = "Number of nodes to be created for the cluster"
  default     = 1
}

variable "add_ons" {
  type        = list(string)
  description = "List of add-ons to be enabled for the Minikube cluster"
  default = [
    "default-storageclass",
    "storage-provisioner",
    "ingress"
  ]
}

variable "wait_for_addons" {
  type = list(string)
  default = [
    "apiserver",
    "system_pods",
    "apps_running"
  ]
}

variable "wait_time" {
  type    = number
  default = 20
}
