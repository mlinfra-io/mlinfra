data "aws_region" "current" {}

# TODO: possibility to bring your own bucket
module "wandb_data_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.wandb_data_bucket_name
  tags        = var.tags
}

resource "aws_iam_policy" "wandb_s3_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "wandbS3AccessPolicy"
  description = "Allows wandb server access to the S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "wandbBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts"
      ],
      "Resource": [
        "${module.wandb_data_artifacts_bucket[0].bucket_arn}",
        "${module.wandb_data_artifacts_bucket[0].bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

# create rds instance
module "wandb_rds_backend" {
  source     = "../../../../../cloud/aws/rds"
  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  vpc_cidr_block       = var.vpc_cidr_block
  db_subnet_group_name = var.db_subnet_group_name
  rds_instance_class   = var.rds_instance_class
  skip_final_snapshot  = var.skip_final_snapshot

  rds_identifier = "wandb-backend"
  db_name        = "wandbbackend"
  db_username    = "wandb_backend_user"
  tags           = var.tags
}

resource "aws_iam_policy" "wandb_rds_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "wandbRDSAccessPolicy"
  description = "Allows wandb helm chart access to the RDS Instance"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:ListTagsForResource",
        "rds:DownloadDBLogFilePortion",
        "rds:DescribeDBLogFiles",
        "rds:DescribeDBClusterSnapshots",
        "rds:DescribeDBSnapshots"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds-db:connect"
      ],
      "Resource": "${module.wandb_rds_backend.db_instance_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "rds:ModifyDBInstance",
          "rds:CreateDBSnapshot",
          "rds:RestoreDBInstanceToPointInTime",
          "rds:DeleteDBInstance",
          "rds:RestoreDBInstanceFromDBSnapshot",
          "rds:RestoreDBInstanceFromS3",
          "rds:StartDBInstance",
          "rds:StopDBInstance"
        ],
      "Resource": "${module.wandb_rds_backend.db_instance_arn}"
    }
  ]
}
EOF
}

locals {
  managed_policy_arns = var.remote_tracking ? [aws_iam_policy.wandb_rds_iam_policy[0].arn] : []
}

resource "aws_iam_role" "wandb_iam_role" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "RoleForWandBWithS3DBAccess"
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
  managed_policy_arns = concat(local.managed_policy_arns, [aws_iam_policy.wandb_s3_iam_policy[0].arn])

  tags = var.tags
}

locals {
  rds_connection_secret = var.remote_tracking ? {
    database_connection_string = "postgresql://${module.wandb_rds_backend.db_instance_username}:${module.wandb_rds_backend.db_instance_password}@${module.wandb_rds_backend.db_instance_endpoint}/${module.wandb_rds_backend.db_instance_name}"
  } : {}
}

# TODO: configuration to add namespace labels & annotations
resource "kubernetes_namespace_v1" "wandb_namespace" {
  metadata {
    name = var.service_account_namespace
    labels = {
      "kubernetes.io/metadata.name" = var.service_account_namespace
      "name"                        = var.service_account_namespace
    }
  }
  depends_on = [aws_iam_role.wandb_iam_role]
}

# TODO: Add secrets store csi driver module to sync secrets
resource "kubernetes_secret_v1" "wandb_secret" {
  metadata {
    name      = var.wandb_secret
    namespace = var.service_account_namespace
  }
  data = local.rds_connection_secret
  type = "Opaque"

  depends_on = [kubernetes_namespace_v1.wandb_namespace]
}

locals {
  wandb_helmchart_values = var.remote_tracking ? [{
    # configuration for remote deployment
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = "${aws_iam_role.wandb_iam_role[0].arn}"
    type  = "auto"
    }, {
    name  = "serviceAccount.name"
    value = var.service_account_name
    type  = "auto"
    }, {
    name  = "backendStore.databaseConnectionCheck"
    value = "true"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.host"
    value = "${replace(module.wandb_rds_backend.db_instance_endpoint, ":5432", "")}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.port"
    value = "5432"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.database"
    value = "${module.wandb_rds_backend.db_instance_name}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.user"
    value = "${module.wandb_rds_backend.db_instance_username}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.password"
    value = "${module.wandb_rds_backend.db_instance_password}"
    type  = "auto"
    }, {
    name  = "artifactRoot.s3.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "artifactRoot.s3.bucket"
    value = "${var.wandb_data_bucket_name}"
    type  = "auto"
  }] : [{}]

  general_configuration = [{
    name  = "license"
    value = "${var.license}"
    type  = "auto"
    }, {
    name  = "enableAdminApi"
    value = "true"
    type  = "auto"
  }]
}

module "wandb_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "wandb"
  namespace        = var.service_account_namespace
  create_namespace = false
  repository       = "https://wandb.github.io/helm-charts"
  chart            = "wandb"
  chart_version    = var.wandb_chart_version
  values = templatefile("${path.module}/values.yaml", {
    nodeSelector = jsonencode(var.nodeSelector)
    tolerations  = jsonencode(var.tolerations)
    affinity     = jsonencode(var.affinity)
    resources    = jsonencode(var.resources)
  })
  set        = concat(local.general_configuration, local.wandb_helmchart_values)
  depends_on = [kubernetes_secret_v1.wandb_secret]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "wandb-secrets"
  secret_value = var.remote_tracking ? {
    bucket_id                  = module.wandb_data_artifacts_bucket[0].bucket_id
    database_connection_string = "postgresql://${module.wandb_rds_backend.db_instance_username}:${module.wandb_rds_backend.db_instance_password}@${module.wandb_rds_backend.db_instance_endpoint}/${module.wandb_rds_backend.db_instance_name}"
    } : {
    bucket_id = module.wandb_data_artifacts_bucket[0].bucket_id
  }

  depends_on = [module.wandb_helmchart]
}
