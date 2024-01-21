locals {
  tags = merge({
    module = path.module
    }, var.tags
  )
}

# TODO: Configure the module completely
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/eks-managed-node-group
module "eks_managed_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "~> 19.20.0"

  for_each = { for k, v in var.node_groups : k => v }

  name            = each.value.name
  cluster_name    = each.value.cluster_name
  cluster_version = each.value.cluster_version

  subnet_ids = each.value.subnet_ids

  // The following variables are necessary if you decide to use the module outside of the parent EKS module context.
  // Without it, the security groups of the nodes are empty and thus won't join the cluster.
  cluster_primary_security_group_id = each.value.cluster_primary_security_group_id
  vpc_security_group_ids            = [each.value.cluster_primary_security_group_id]

  create_launch_template     = try(each.value.create_launch_template, var.create_launch_template)
  use_custom_launch_template = try(each.value.use_custom_launch_template, var.use_custom_launch_template)

  instance_types = try(each.value.instance_types, var.instance_types)
  ami_type       = try(each.value.ami_type, var.ami_type)
  capacity_type  = try(each.value.spot_instance, var.spot_instance) ? "SPOT" : "ON_DEMAND"
  min_size       = try(each.value.min_size, var.min_size)
  max_size       = try(each.value.max_size, var.max_size)
  desired_size   = try(each.value.desired_size, var.desired_size)
  disk_size      = try(each.value.disk_size, var.disk_size)

  labels = try(each.value.labels, var.labels)
  taints = try(each.value.taints, var.taints)
  tags   = local.tags
}
