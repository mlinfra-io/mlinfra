data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  aws_region         = data.aws_region.current.name
  availability_zones = data.aws_availability_zones.available.names
}

# TODO: possibility to bring your own bucket
module "milvus_data_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.milvus_storage_bucket
  tags        = var.tags
}

resource "aws_iam_policy" "milvus_s3_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "MilvusS3AccessPolicy-"
  description = "Allows Milvus server access to the S3 bucket for data storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MilvusBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ]
        Resource = [
          module.milvus_data_artifacts_bucket[0].bucket_arn,
          "${module.milvus_data_artifacts_bucket[0].bucket_arn}/*"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "MilvusS3AccessPolicy"
    Purpose = "Milvus data storage"
  })
}

resource "aws_iam_role" "milvus_iam_role" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "RoleForMilvusWithS3Access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : var.oidc_provider_arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${var.oidc_provider}:aud" : "sts.amazonaws.com",
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })
  managed_policy_arns = [aws_iam_policy.milvus_s3_iam_policy[0].arn]

  tags = var.tags
}

resource "null_resource" "unset_default_storage_class" {
  provisioner "local-exec" {
    command    = <<-EOT
      kubectl patch storageclass gp2 -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    EOT
    on_failure = continue
  }

  triggers = {
    always_run = "${timestamp()}"
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_iam_role.milvus_iam_role]
}

resource "kubernetes_storage_class" "ebs_gp3_sc" {
  metadata {
    name = "ebs-gp3-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  allowed_topologies {
    match_label_expressions {
      key    = "topology.ebs.csi.aws.com/zone"
      values = [for az in local.availability_zones : az]
    }
  }
  parameters = {
    type = "gp3"
  }
}


locals {
  milvus_helmchart_set = var.remote_tracking ? [{
    name  = "cluster.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "serviceAccount.create"
    value = "true"
    type  = "auto"
    }, {
    name  = "serviceAccount.name"
    value = "${var.service_account_name}"
    type  = "auto"
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "${aws_iam_role.milvus_iam_role[0].arn}"
    type  = "auto"
    }, {
    name  = "minio.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "externalS3.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "externalS3.host"
    value = "s3.${local.aws_region}.amazonaws.com"
    type  = "auto"
    }, {
    name  = "externalS3.port"
    value = "443"
    type  = "auto"
    }, {
    name  = "externalS3.useSSL"
    value = "true"
    type  = "auto"
    }, {
    name  = "externalS3.bucketName"
    value = "${module.milvus_data_artifacts_bucket[0].bucket_id}"
    type  = "auto"
    }, {
    name  = "externalS3.useIAM"
    value = "true"
    type  = "auto"
    }, {
    name  = "externalS3.cloudProvider"
    value = "aws"
    type  = "auto"
    }, {
    name  = "rootCoordinator.replicas"
    value = "2"
    type  = "auto"
    }, {
    name  = "rootCoordinator.activeStandby.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "rootCoordinator.resources.limits.cpu"
    value = "1"
    type  = "auto"
    }, {
    name  = "rootCoordinator.resources.limits.memory"
    value = "2Gi"
    type  = "auto"
    }, {
    name  = "indexCoordinator.replicas"
    value = "2"
    type  = "auto"
    }, {
    name  = "indexCoordinator.activeStandby.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "indexCoordinator.resources.limits.cpu"
    value = "0.5"
    type  = "auto"
    }, {
    name  = "indexCoordinator.resources.limits.memory"
    value = "0.5Gi"
    type  = "auto"
    }, {
    name  = "queryCoordinator.replicas"
    value = "2"
    type  = "auto"
    }, {
    name  = "queryCoordinator.activeStandby.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "queryCoordinator.resources.limits.cpu"
    value = "0.5"
    type  = "auto"
    }, {
    name  = "queryCoordinator.resources.limits.memory"
    value = "0.5Gi"
    type  = "auto"
    }, {
    name  = "dataCoordinator.replicas"
    value = "2"
    type  = "auto"
    }, {
    name  = "dataCoordinator.activeStandby.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "dataCoordinator.resources.limits.cpu"
    value = "0.5"
    type  = "auto"
    }, {
    name  = "dataCoordinator.resources.limits.memory"
    value = "0.5Gi"
    type  = "auto"
    }, {
    name  = "proxy.replicas"
    value = "2"
    type  = "auto"
    }, {
    name  = "proxy.resources.limits.cpu"
    value = "1"
    type  = "auto"
    }, {
    name  = "proxy.resources.limits.memory"
    value = "2Gi"
    type  = "auto"
    }, {
    name  = "attu.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "service.type"
    value = "LoadBalancer"
    type  = "auto"
    }, {
    name  = "service.port"
    value = "19530"
    type  = "auto"
    }, {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "external"
    type  = "auto"
    }, {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-name"
    value = "milvus-service"
    type  = "auto"
    }, {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internal"
    type  = "auto"
    }, {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-nlb-target-type"
    value = "ip"
    type  = "auto"
    }, {
    name  = "standalone.persistence.enabled"
    value = "false"
    type  = "auto"
    }] : [{
    name  = "cluster.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "pulsar.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "etcd.replicaCount"
    value = "1"
    type  = "auto"
    }, {
    name  = "minio.mode"
    value = "standalone"
    type  = "auto"
    }, {
    name  = "attu.enabled"
    value = "true"
    type  = "auto"
  }]
}

module "milvus_helmchart" {
  source           = "../../../../../cloud/aws/helm_chart"
  name             = "milvus"
  namespace        = var.service_account_namespace
  create_namespace = true
  repository       = "https://zilliztech.github.io/milvus-helm/"
  chart            = "milvus"
  chart_version    = var.milvus_chart_version
  values = templatefile("${path.module}/values.yaml", {
    remote_tracking = jsonencode(var.remote_tracking)
    nodeSelector    = jsonencode(var.nodeSelector)
    tolerations     = jsonencode(var.tolerations)
    affinity        = jsonencode(var.affinity)
    resources       = jsonencode(var.resources)
  })
  timeout = 600
  set     = local.milvus_helmchart_set

  depends_on = [aws_iam_role.milvus_iam_role, kubernetes_storage_class.ebs_gp3_sc]
}
