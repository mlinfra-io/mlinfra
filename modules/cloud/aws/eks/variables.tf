variable "aws_kms_key" {
  type = object({
    description             = string
    deletion_window_in_days = number
    enable_key_rotation     = bool
    tags                    = map(string)
  })
  default = {
    description             = "KMS Key for EKS"
    deletion_window_in_days = 14
    enable_key_rotation     = true
    tags                    = {}
  }
}

variable "aws_eks_cluster" {
  type = object({
    cluster_name                    = string
    cluster_version                 = string
    cluster_endpoint_private_access = bool
    cluster_endpoint_public_access  = bool
    vpc_id                          = string
    subnets                         = list(string)
    cluster_ip_family               = string
    control_plane_subnet_ids        = list(string)
    tags                            = map(any)
  })
}

variable "cluster_security_group_additional_rules" {
  type = map(object({
    description                = string
    protocol                   = string
    from_port                  = number
    to_port                    = number
    type                       = string
    source_node_security_group = bool
  }))
  default = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To ports 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }
}

variable "node_security_group_additional_rules" {
  type = map(object({
    description      = string
    protocol         = string
    from_port        = number
    to_port          = number
    type             = string
    self             = optional(bool)
    cidr_blocks      = optional(list(string))
    ipv6_cidr_blocks = optional(list(string))
  }))
  default = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

variable "eks_managed_node_groups" {
  type = map(object({
    create_launch_template = bool
    launch_template_name   = string
    ami_type               = string
    disk_size              = number
    min_size               = number
    max_size               = number
    desired_size           = number
    capacity_type          = string
    force_update_version   = bool
    instance_types         = list(string)
    labels                 = optional(map(string))
    taints                 = list(map(string))
  }))
}

variable "vpc_cni_irsa" {
  type = object({
    role_name_prefix      = string
    attach_vpc_cni_policy = bool
    vpc_cni_enable_ipv4   = bool
    tags                  = map(string)
  })
  default = {
    role_name_prefix      = "VPC-CNI-IRSA"
    attach_vpc_cni_policy = true
    vpc_cni_enable_ipv4   = true
    tags                  = {}
  }
}

variable "vpc_cni_addon" {
  type = object({
    before_compute              = bool
    most_recent                 = bool
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
    configuration_values        = map(any)
  })
  default = {
    before_compute              = true
    most_recent                 = true
    resolve_conflicts_on_create = "OVERWRITE"
    resolve_conflicts_on_update = "PRESERVE"
    configuration_values = {
      env = {
        ENABLE_PREFIX_DELEGATION = "true"
        WARM_PREFIX_TARGET       = "1"
      }
    }
  }
}

variable "ebs_csi_driver_irsa" {
  type = object({
    role_name_prefix      = string
    attach_ebs_csi_policy = bool
    tags                  = map(string)
  })
  default = {
    role_name_prefix      = "EBS-CSI-IRSA"
    attach_ebs_csi_policy = true
    tags                  = {}
  }
}
