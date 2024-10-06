# TODO: organise the variables in an object
# check and verify the variables in a try block afterwards, passing
# the defaults there.

variable "node_groups" {
  description = "Map of EKS managed node group definitions to create"
  type        = any
  default     = {}
}

# TODO: Simplify this to just cpu or gpu
variable "ami_type" {
  type        = string
  description = "The AMI type to use for the worker nodes."
  default     = "AL2_x86_64"
  validation {
    condition     = var.ami_type == "AL2_x86_64" || var.ami_type == "AL2_x86_64_GPU"
    error_message = "The ami type must be either AL2_x86_64 or AL2_x86_64_GPU"
  }
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "eks-cluster"
}

variable "cluster_version" {
  type        = string
  description = "EKS Cluster version"
  default     = "1.30"
}

variable "nodegroup_name" {
  type        = string
  description = "The name of the node group."
  default     = "default_nodegroup"
}

variable "create_launch_template" {
  type        = bool
  description = "Create a launch template for the node group."
  default     = false
}

variable "use_custom_launch_template" {
  type        = bool
  description = "Use a custom launch template for the node group."
  default     = false
}

variable "instance_types" {
  type        = list(string)
  description = "The instance types associated with the node group."
  default     = ["t3.medium"]
}

variable "disk_size" {
  type        = number
  description = "The size in GiB of the EBS volume for each node in the node group."
  default     = 20
}

variable "min_size" {
  type        = number
  description = "The minimum size of the node group."
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The maximum size of the node group."
  default     = 5
}

variable "desired_size" {
  type        = number
  description = "The number of worker nodes that should be running in the cluster."
  default     = 3
}

variable "spot_instance" {
  type        = bool
  description = "The capacity type of the node group."
  default     = true
}

variable "labels" {
  type        = map(string)
  description = ""
  default     = {}
}

variable "taints" {
  type = map(object({
    key    = string
    value  = string
    effect = string
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the EKS cluster and related modules."
  default     = {}
}
