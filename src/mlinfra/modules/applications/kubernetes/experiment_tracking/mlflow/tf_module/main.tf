data "aws_region" "current" {}

# TODO: possibility to bring your own bucket
module "mlflow_data_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.mlflow_data_bucket_name
  tags        = var.tags
}

resource "aws_iam_policy" "mlflow_s3_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "MLFlowS3Access-"
  description = "Allows MLflow server access to the S3 bucket for artifact storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "MLFlowBucketAccess"
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
          module.mlflow_data_artifacts_bucket[0].bucket_arn,
          "${module.mlflow_data_artifacts_bucket[0].bucket_arn}/*"
        ]
      },
      {
        Sid      = "MLFlowBucketList"
        Effect   = "Allow"
        Action   = ["s3:ListAllMyBuckets"]
        Resource = ["*"]
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "MLFlowS3AccessPolicy"
    Purpose = "MLflow artifact storage"
  })
}

# create rds instance
module "mlflow_rds_backend" {
  source     = "../../../../../cloud/aws/rds"
  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  vpc_cidr_block       = var.vpc_cidr_block
  db_subnet_group_name = var.db_subnet_group_name
  rds_instance_class   = var.rds_instance_class
  skip_final_snapshot  = var.skip_final_snapshot

  rds_identifier = "mlflow-backend"
  db_name        = "mlflowbackend"
  db_username    = "mlflow_backend_user"
  tags           = var.tags
}

resource "aws_iam_policy" "mlflow_rds_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "mlflowRDSAccessPolicy"
  description = "Allows mlflow helm chart access to the RDS Instance"

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
      "Resource": "${module.mlflow_rds_backend.db_instance_arn}"
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
      "Resource": "${module.mlflow_rds_backend.db_instance_arn}"
    }
  ]
}
EOF
}

locals {
  managed_policy_arns = var.remote_tracking ? [aws_iam_policy.mlflow_rds_iam_policy[0].arn] : []
}

resource "aws_iam_role" "mlflow_iam_role" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "RoleFormlflowWithS3DBAccess"
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
  managed_policy_arns = concat(local.managed_policy_arns, [aws_iam_policy.mlflow_s3_iam_policy[0].arn])

  tags = var.tags
}

locals {
  rds_connection_secret = var.remote_tracking ? {
    database_connection_string = "postgresql://${module.mlflow_rds_backend.db_instance_username}:${module.mlflow_rds_backend.db_instance_password}@${module.mlflow_rds_backend.db_instance_endpoint}/${module.mlflow_rds_backend.db_instance_name}"
  } : {}
}

# TODO: configuration to add namespace labels & annotations
resource "kubernetes_namespace_v1" "mlflow_namespace" {
  metadata {
    name = var.service_account_namespace
    labels = {
      "kubernetes.io/metadata.name" = var.service_account_namespace
      "name"                        = var.service_account_namespace
    }
  }
  depends_on = [aws_iam_role.mlflow_iam_role]
}

# TODO: Add secrets store csi driver module to sync secrets
resource "kubernetes_secret_v1" "mlflow_secret" {
  metadata {
    name      = var.mlflow_secret
    namespace = var.service_account_namespace
  }
  data = local.rds_connection_secret
  type = "Opaque"

  depends_on = [kubernetes_namespace_v1.mlflow_namespace]
}

locals {
  mlflow_helmchart_values = var.remote_tracking ? [{
    # configuration for remote deployment
    name  = "serviceAccount.create"
    value = "true"
    type  = "auto"
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = "${aws_iam_role.mlflow_iam_role[0].arn}"
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
    value = "${replace(module.mlflow_rds_backend.db_instance_endpoint, ":5432", "")}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.port"
    value = "5432"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.database"
    value = "${module.mlflow_rds_backend.db_instance_name}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.user"
    value = "${module.mlflow_rds_backend.db_instance_username}"
    type  = "auto"
    }, {
    name  = "backendStore.postgres.password"
    value = "${module.mlflow_rds_backend.db_instance_password}"
    type  = "auto"
    }, {
    name  = "artifactRoot.s3.enabled"
    value = "true"
    type  = "auto"
    }, {
    name  = "artifactRoot.s3.bucket"
    value = "${var.mlflow_data_bucket_name}"
    type  = "auto"
    }] : [{
    # configuration for non remote deployment
    name  = "backendStore.postgres.enabled"
    value = "false"
    type  = "auto"
    }, {
    name  = "artifactRoot.s3.enabled"
    value = "false"
    type  = "auto"
  }]
}

module "mlflow_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "mlflow"
  namespace        = var.service_account_namespace
  create_namespace = true
  repository       = "https://community-charts.github.io/helm-charts"
  chart            = "mlflow"
  chart_version    = var.mlflow_chart_version
  values = templatefile("${path.module}/values.yaml", {
    nodeSelector = jsonencode(var.nodeSelector)
    tolerations  = jsonencode(var.tolerations)
    affinity     = jsonencode(var.affinity)
    resources    = jsonencode(var.resources)
  })
  set        = local.mlflow_helmchart_values
  depends_on = [kubernetes_secret_v1.mlflow_secret]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "mlflow-secrets"
  secret_value = var.remote_tracking ? {
    bucket_id                  = module.mlflow_data_artifacts_bucket[0].bucket_id
    database_connection_string = "postgresql://${module.mlflow_rds_backend.db_instance_username}:${module.mlflow_rds_backend.db_instance_password}@${module.mlflow_rds_backend.db_instance_endpoint}/${module.mlflow_rds_backend.db_instance_name}"
    } : {
    bucket_id = module.mlflow_data_artifacts_bucket[0].bucket_id
  }

  depends_on = [module.mlflow_helmchart]
}
