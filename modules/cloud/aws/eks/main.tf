data "aws_caller_identity" "current" {}

locals {
  cluster_tags = merge({
    Name   = var.aws_eks_cluster.cluster_name,
    Module = path.module
    }, var.aws_eks_cluster.tags
  )
}

resource "aws_kms_key" "eks" {
  description             = var.aws_kms_key.description
  deletion_window_in_days = var.aws_kms_key.deletion_window_in_days
  enable_key_rotation     = var.aws_kms_key.enable_key_rotation
  tags                    = var.aws_kms_key.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                    = var.aws_eks_cluster.cluster_name
  cluster_version                 = var.aws_eks_cluster.cluster_version
  cluster_endpoint_private_access = var.aws_eks_cluster.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.aws_eks_cluster.cluster_endpoint_public_access

  vpc_id = var.aws_eks_cluster.vpc_id
  # set to private subnets if cluster is in private subnets
  subnet_ids        = var.aws_eks_cluster.subnets
  cluster_ip_family = var.aws_eks_cluster.cluster_ip_family
  # set to private subnets if cluster is in private subnets
  control_plane_subnet_ids = var.aws_eks_cluster.control_plane_subnet_ids

  create_kms_key = false
  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  cluster_addons = {
    vpc-cni = {
      # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      before_compute              = true
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      service_account_role_arn    = module.vpc_cni_irsa.iam_role_arn
      configuration_values = {
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      }
    }
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      configuration_values = jsonencode({
        affinity = {
          nodeAffinity = {
            requiredDuringSchedulingIgnoredDuringExecution = {
              nodeSelectorTerms = [{
                matchExpressions = [{
                  key      = "nodegroup_type"
                  operator = "In"
                  values   = "operations"
                }]
              }]
            }
          }
        }
        tolerations = [{
          key      = "nodegroup_type"
          operator = "Equal"
          value    = "operations"
          effect   = "NoSchedule"
        }]
      })
    }
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
    }
    aws-ebs-csi-driver = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
      service_account_role_arn    = module.ebs_csi_driver_irsa.iam_role_arn
      configuration_values = jsonencode({
        controller = {
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "nodegroup_type"
                    operator = "In"
                    values   = "operations"
                  }]
                }]
              }
            }
          }
          tolerations = [{
            key      = "nodegroup_type"
            operator = "Equal"
            value    = "operations"
            effect   = "NoSchedule"
          }]
        }
        node = {
          affinity = {
            nodeAffinity = {
              requiredDuringSchedulingIgnoredDuringExecution = {
                nodeSelectorTerms = [{
                  matchExpressions = [{
                    key      = "nodegroup_type"
                    operator = "In"
                    values   = "operations"
                  }]
                }]
              }
            }
          }
          tolerations = [{
            key      = "nodegroup_type"
            operator = "Equal"
            value    = "operations"
            effect   = "NoSchedule"
          }]
        }
      })
    }
  }

  # Extend cluster security group rules
  cluster_security_group_additional_rules = var.aws_eks_cluster.cluster_security_group_additional_rules

  # Extend node-to-node security group rules
  node_security_group_additional_rules = var.aws_eks_cluster.node_security_group_additional_rules

  eks_managed_node_group_defaults = {}

  eks_managed_node_groups = var.aws_eks_cluster.eks_managed_node_groups

  # update tags
  tags = var.aws_eks_cluster.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name_prefix      = var.vpc_cni_irsa.role_name_prefix
  attach_vpc_cni_policy = var.vpc_cni_irsa.attach_vpc_cni_policy
  vpc_cni_enable_ipv4   = var.vpc_cni_irsa.vpc_cni_enable_ipv4

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  # update tags
  tags = var.aws_eks_cluster.tags
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.30"

  role_name_prefix      = var.ebs_csi_driver_irsa.role_name_prefix
  attach_ebs_csi_policy = var.ebs_csi_driver_irsa.attach_ebs_csi_policy

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  # update tags
  tags = var.aws_eks_cluster.tags
}

# source:
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/51cc6bec880ac8dc361b60a4b05d5f2bcd98eb6a/examples/eks_managed_node_group/main.tf#L462-L509
################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {

  # We need to lookup K8s taint effect from the AWS API value
  taint_effects = {
    NO_SCHEDULE        = "NoSchedule"
    NO_EXECUTE         = "NoExecute"
    PREFER_NO_SCHEDULE = "PreferNoSchedule"
  }

  cluster_autoscaler_label_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for label_name, label_value in coalesce(group.node_group_labels, {}) : "${name}|label|${label_name}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/label/${label_name}",
        value             = label_value,
      }
    }
  ]...)

  cluster_autoscaler_taint_tags = merge([
    for name, group in module.eks.eks_managed_node_groups : {
      for taint in coalesce(group.node_group_taints, []) : "${name}|taint|${taint.key}" => {
        autoscaling_group = group.node_group_autoscaling_group_names[0],
        key               = "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}"
        value             = "${taint.value}:${local.taint_effects[taint.effect]}"
      }
    }
  ]...)

  cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags)
}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_label_tags" {
  for_each = local.cluster_autoscaler_asg_tags

  autoscaling_group_name = each.value.autoscaling_group

  tag {
    key   = each.value.key
    value = each.value.value

    propagate_at_launch = false
  }
}
