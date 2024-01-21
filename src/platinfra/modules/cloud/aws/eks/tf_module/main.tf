locals {
  tags = merge({
    name   = var.cluster_name
    module = path.module
    }, var.tags
  )
}

# TODO: add kms policy to restrict kms key access
# TODO: update aws provider version when this issue gets fixed
# https://github.com/hashicorp/terraform-provider-aws/issues/34538
resource "aws_kms_key" "eks" {
  description             = "KMS Key for EKS Secrets encryption"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_rotation
  tags                    = local.tags
}

resource "aws_kms_alias" "eks_key_alias" {
  name_prefix   = "alias/${var.cluster_name}-secrets-encryption-key"
  target_key_id = aws_kms_key.eks.key_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.k8s_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  cluster_ip_family        = var.cluster_ip_family
  control_plane_subnet_ids = var.subnet_ids

  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }

  cluster_addons = {
    vpc-cni = {
      # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      before_compute              = var.vpc_cni_addon.before_compute
      most_recent                 = var.vpc_cni_addon.most_recent
      resolve_conflicts_on_create = var.vpc_cni_addon.resolve_conflicts_on_create
      resolve_conflicts_on_update = var.vpc_cni_addon.resolve_conflicts_on_update
      service_account_role_arn    = module.vpc_cni_irsa.iam_role_arn
      configuration_values        = jsonencode(var.vpc_cni_addon_configuration_values)
    }
    coredns = {
      most_recent                 = var.coredns_addon.most_recent
      resolve_conflicts_on_create = var.coredns_addon.resolve_conflicts_on_create
      resolve_conflicts_on_update = var.coredns_addon.resolve_conflicts_on_update
      configuration_values        = jsonencode(var.coredns_addon_configuration_values)
    }
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "PRESERVE"
    }
    aws-ebs-csi-driver = {
      most_recent                 = var.ebs_csi_driver_addon.most_recent
      resolve_conflicts_on_create = var.ebs_csi_driver_addon.resolve_conflicts_on_create
      resolve_conflicts_on_update = var.ebs_csi_driver_addon.resolve_conflicts_on_update
      service_account_role_arn    = module.ebs_csi_driver_irsa.iam_role_arn
      configuration_values        = jsonencode(var.ebs_csi_driver_addon_configuration_values)
    }
  }

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules    = var.node_security_group_additional_rules

  # TODO: cannot pass it as a variable
  # eks_managed_node_group_defaults = var.eks_managed_node_group_defaults
  eks_managed_node_group_defaults = {
    ebs_optimized                         = true
    attach_cluster_primary_security_group = true
  }

  # Default node group that comes with the cluster
  eks_managed_node_groups = {
    "${var.nodegroup_name}" = {
      create_launch_template     = var.create_launch_template
      use_custom_launch_template = var.use_custom_launch_template
      ami_type                   = var.ami_type

      disk_size    = var.disk_size
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      capacity_type  = var.spot_instance ? "SPOT" : "ON_DEMAND"
      instance_types = var.instance_types

      labels = var.labels
      taints = var.taints
      tags   = local.tags
    }
  }
  # update tags
  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33.0"

  # TODO: add support for ipv6
  role_name_prefix      = var.vpc_cni_irsa_role_name_prefix
  attach_vpc_cni_policy = var.vpc_cni_irsa.attach_vpc_cni_policy
  vpc_cni_enable_ipv4   = var.vpc_cni_irsa.vpc_cni_enable_ipv4

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = local.tags
}

module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33.0"

  role_name_prefix      = var.ebs_csi_driver_irsa_role_name_prefix
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

# source:
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/51cc6bec880ac8dc361b60a4b05d5f2bcd98eb6a/examples/eks_managed_node_group/main.tf#L462-L509
################################################################################
# Tags for the ASG to support cluster-autoscaler scale up from 0
################################################################################

locals {
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
    key                 = each.value.key
    value               = each.value.value
    propagate_at_launch = false
  }
}
