data "aws_region" "current" {}

resource "random_password" "lakefs_auth_key" {
  count = var.remote_tracking ? 1 : 0

  length           = 64
  special          = false
  override_special = "_%@"
}

# TODO: possibility to bring your own bucket
module "lakefs_data_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.lakefs_data_bucket_name
  tags        = var.tags
}

resource "aws_iam_policy" "lakefs_s3_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "LakeFSS3AccessPolicy"
  description = "Allows LakeFS server access to the S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "lakeFSBucketAccess",
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
        "${module.lakefs_data_artifacts_bucket[0].bucket_arn}",
        "${module.lakefs_data_artifacts_bucket[0].bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

# create rds instance
module "lakefs_rds_backend" {
  source     = "../../../../../cloud/aws/rds"
  create_rds = (var.remote_tracking && var.database_type == "postgres")

  vpc_id               = var.vpc_id
  vpc_cidr_block       = var.vpc_cidr_block
  db_subnet_group_name = var.db_subnet_group_name
  rds_instance_class   = var.rds_instance_class
  skip_final_snapshot  = var.skip_final_snapshot

  rds_identifier = "lakefs-backend"
  db_name        = "lakefsbackend"
  db_username    = "lakefs_backend_user"
  tags           = var.tags
}

resource "aws_dynamodb_table" "dynamodb_table" {
  count        = (var.remote_tracking && var.database_type == "dynamodb") ? 1 : 0
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "PartitionKey"
    type = "B"
  }

  attribute {
    name = "ItemKey"
    type = "B"
  }

  hash_key  = "PartitionKey"
  range_key = "ItemKey"

  tags = var.tags
}

resource "aws_iam_policy" "lakefs_rds_iam_policy" {
  count       = (var.remote_tracking && var.database_type == "postgres") ? 1 : 0
  name_prefix = "LakeFSRDSAccessPolicy"
  description = "Allows LakeFS helm chart access to the RDS Instance"

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
      "Resource": "${module.lakefs_rds_backend.db_instance_arn}"
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
      "Resource": "${module.lakefs_rds_backend.db_instance_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lakefs_dynamodb_iam_policy" {
  count       = (var.remote_tracking && var.database_type == "dynamodb") ? 1 : 0
  name_prefix = "LakeFSDynamodbAccessPolicy"
  description = "Allows LakeFS server access to the Dynamodb"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "ListAndDescribe",
        "Effect": "Allow",
        "Action": [
            "dynamodb:List*",
            "dynamodb:DescribeReservedCapacity*",
            "dynamodb:DescribeLimits",
            "dynamodb:DescribeTimeToLive"
        ],
        "Resource": "*"
    },
    {
        "Sid": "DynamodbTableAccess",
        "Effect": "Allow",
        "Action": [
            "dynamodb:BatchGet*",
            "dynamodb:DescribeTable",
            "dynamodb:Get*",
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:BatchWrite*",
            "dynamodb:CreateTable",
            "dynamodb:Delete*",
            "dynamodb:Update*",
            "dynamodb:PutItem"
        ],
        "Resource": "${aws_dynamodb_table.dynamodb_table[0].arn}"
    }
  ]
}
EOF
}

locals {
  managed_policy_arns = var.remote_tracking ? var.database_type == "postgres" ? [aws_iam_policy.lakefs_rds_iam_policy[0].arn] : [aws_iam_policy.lakefs_dynamodb_iam_policy[0].arn] : []
}

resource "aws_iam_role" "lakefs_iam_role" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "RoleForLakeFSWithS3DBAccess"
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
  managed_policy_arns = concat(local.managed_policy_arns, [aws_iam_policy.lakefs_s3_iam_policy[0].arn])

  tags = var.tags
}

locals {
  secret_data = var.remote_tracking ? var.database_type == "postgres" ? {
    auth_encrypt_secret_key    = resource.random_password.lakefs_auth_key[0].result
    database_connection_string = "postgresql://${module.lakefs_rds_backend.db_instance_username}:${module.lakefs_rds_backend.db_instance_password}@${module.lakefs_rds_backend.db_instance_endpoint}/${module.lakefs_rds_backend.db_instance_name}"
    } : {
    auth_encrypt_secret_key = resource.random_password.lakefs_auth_key[0].result
  } : {}
}

# TODO: configuration to add namespace labels & annotations
resource "kubernetes_namespace_v1" "lakefs_namespace" {
  metadata {
    name = var.service_account_namespace
    labels = {
      "kubernetes.io/metadata.name" = var.service_account_namespace
      "name"                        = var.service_account_namespace
    }
  }
  depends_on = [aws_iam_role.lakefs_iam_role]
}

# TODO: Add secrets store csi driver module to sync secrets
resource "kubernetes_secret_v1" "lakefs_secret" {
  metadata {
    name      = var.lakefs_secret
    namespace = var.service_account_namespace
  }
  data = local.secret_data
  type = "Opaque"

  depends_on = [kubernetes_namespace_v1.lakefs_namespace]
}

resource "kubernetes_service_account_v1" "lakefs_sa" {
  count = var.remote_tracking ? 1 : 0
  metadata {
    name      = var.service_account_name
    namespace = var.service_account_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.lakefs_iam_role[0].arn
    }
  }
  depends_on = [aws_iam_role.lakefs_iam_role, kubernetes_namespace_v1.lakefs_namespace]
}

locals {
  lakefs_config_filename = var.remote_tracking ? "lakefs-${var.database_type}-config.tpl" : null
  lakefs_config = var.remote_tracking ? var.database_type == "postgres" ? templatefile("${path.module}/${local.lakefs_config_filename}", {
    region = data.aws_region.current.name
    }) : templatefile("${path.module}/${local.lakefs_config_filename}", {
    dynamodb_table_name = var.dynamodb_table_name
    region              = data.aws_region.current.name
  }) : null
  lakefs_helmchart_set = var.remote_tracking ? [{
    name  = "lakefsConfig"
    value = "${local.lakefs_config}"
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
    name  = "existingSecret"
    value = "${var.lakefs_secret}"
    type  = "auto"
    }, {
    name  = "secretKeys.databaseConnectionString"
    value = var.database_type == "postgres" ? "database_connection_string" : "null"
    type  = "auto"
    }] : [{
    name  = "blockstore.s3.region"
    value = "${data.aws_region.current.name}"
    type  = "auto"
  }]
}

module "lakefs_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "lakefs"
  namespace        = var.service_account_namespace
  create_namespace = false
  repository       = "https://charts.lakefs.io"
  chart            = "lakefs"
  chart_version    = var.lakefs_chart_version
  values = templatefile("${path.module}/values.yaml", {
    nodeSelector = jsonencode(var.nodeSelector)
    tolerations  = jsonencode(var.tolerations)
    affinity     = jsonencode(var.affinity)
    resources    = jsonencode(var.resources)
  })
  set = concat(local.lakefs_helmchart_set, [{
    name  = "useDevPostgres"
    value = var.remote_tracking ? "false" : "true"
    type  = "auto"
  }])

  depends_on = [kubernetes_service_account_v1.lakefs_sa]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "lakefs-secrets"
  secret_value = var.remote_tracking ? var.database_type == "postgres" ? {
    auth_secret_key            = resource.random_password.lakefs_auth_key[0].result
    bucket_id                  = module.lakefs_data_artifacts_bucket[0].bucket_id
    database_connection_string = "postgresql://${module.lakefs_rds_backend.db_instance_username}:${module.lakefs_rds_backend.db_instance_password}@${module.lakefs_rds_backend.db_instance_endpoint}/${module.lakefs_rds_backend.db_instance_name}"
    } : {
    auth_secret_key = resource.random_password.lakefs_auth_key[0].result
    bucket_id       = module.lakefs_data_artifacts_bucket[0].bucket_id
    } : {
    bucket_id = module.lakefs_data_artifacts_bucket[0].bucket_id
  }

  depends_on = [module.lakefs_helmchart]
}
