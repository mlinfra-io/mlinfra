# create rds instance
module "prefect_rds_backend" {
  source = "../../../../../cloud/aws/rds"

  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block
  rds_instance_class   = var.rds_instance_class
  skip_final_snapshot  = var.skip_final_snapshot

  rds_identifier = "prefect-backend"
  db_name        = "prefectbackend"
  db_username    = "prefect_backend_user"
  tags           = var.tags
}

resource "aws_iam_policy" "prefect_rds_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "PrefectRDSAccessPolicy"
  description = "Allows prefect helm chart access to the RDS Instance"

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
      "Resource": "${module.prefect_rds_backend.db_instance_arn}"
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
      "Resource": "${module.prefect_rds_backend.db_instance_arn}"
    }
  ]
}
EOF
}

locals {
  managed_policy_arns = var.remote_tracking ? [aws_iam_policy.prefect_rds_iam_policy[0].arn] : []
}

resource "aws_iam_role" "prefect_server_iam_role" {
  count       = var.remote_tracking ? 1 : 0
  name_prefix = "PrefectServerAccess"
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
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.service_account_namespace}:${var.prefect_server_service_account_name}"
          }
        }
      }
    ]
  })
  managed_policy_arns = local.managed_policy_arns

  tags = var.tags
}

locals {
  rds_connection_secret = var.remote_tracking ? {
    connection-string = "postgresql+asyncpg://${module.prefect_rds_backend.db_instance_username}:${module.prefect_rds_backend.db_instance_password}@${module.prefect_rds_backend.db_instance_endpoint}/${module.prefect_rds_backend.db_instance_name}"
    password          = "${module.prefect_rds_backend.db_instance_password}"
  } : {}
}

resource "kubernetes_namespace_v1" "prefect_namespace" {
  metadata {
    name = var.service_account_namespace
    labels = {
      "kubernetes.io/metadata.name" = var.service_account_namespace
      "name"                        = var.service_account_namespace
    }
  }
  depends_on = [module.prefect_rds_backend, aws_iam_role.prefect_server_iam_role]
}

resource "kubernetes_secret_v1" "prefect_secret" {
  metadata {
    name      = var.prefect_secret
    namespace = var.service_account_namespace
  }
  data = local.rds_connection_secret
  type = "Opaque"

  depends_on = [kubernetes_namespace_v1.prefect_namespace]
}

locals {
  prefect_server_helmchart_values = var.remote_tracking ? [{
    # configuration for remote deployment
    name  = "serviceAccount.create"
    value = "true"
    type  = "auto"
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = "${aws_iam_role.prefect_server_iam_role[0].arn}"
    type  = "auto"
    }, {
    name  = "serviceAccount.name"
    value = var.prefect_server_service_account_name
    type  = "auto"
    }, {
    name  = "postgresql.useSubChart"
    value = "false"
    type  = "auto"
    }, {
    name  = "postgresql.externalHostname"
    value = "${replace(module.prefect_rds_backend.db_instance_endpoint, ":5432", "")}"
    type  = "auto"
    }, {
    name  = "postgresql.auth.database"
    value = "${module.prefect_rds_backend.db_instance_name}"
    type  = "auto"
    }, {
    name  = "postgresql.auth.username"
    value = "${module.prefect_rds_backend.db_instance_username}"
    type  = "auto"
    }, {
    name  = "postgresql.auth.password"
    value = "${module.prefect_rds_backend.db_instance_password}"
    type  = "auto"
    }, {
    name  = "postgresql.auth.existingSecret"
    value = "${var.prefect_secret}"
    type  = "auto"
    }] : [{
    # configuration for non remote deployment
    name  = "postgresql.useSubChart"
    value = "true"
    type  = "auto"
    }, {
    name  = "postgresql.primary.persistence.enabled"
    value = "true"
    type  = "auto"
  }]
}

module "prefect_server_helmchart" {
  source = "../../../../../cloud/aws/helm_chart"

  name             = "prefect-server"
  namespace        = var.service_account_namespace
  create_namespace = false
  repository       = "https://prefecthq.github.io/prefect-helm"
  chart            = "prefect-server"
  chart_version    = var.prefect_chart_version
  values = templatefile("${path.module}/values.yaml", {
    prefect_deplyoment_type = "server"
    nodeSelector            = jsonencode(var.nodeSelector)
    tolerations             = jsonencode(var.tolerations)
    affinity                = jsonencode(var.affinity)
    resources               = jsonencode(var.resources)
  })
  set = concat(local.prefect_server_helmchart_values, [{
    name  = "postgresql.enabled"
    value = "true"
    type  = "auto"
  }])
  depends_on = [kubernetes_secret_v1.prefect_secret]
}

resource "aws_iam_role" "prefect_worker_iam_role" {
  count       = var.create_prefect_kubernetes_worker ? 1 : 0
  name_prefix = "PrefectWorkerAccess"
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
            "${var.oidc_provider}:sub" : "system:serviceaccount:${var.service_account_namespace}:${var.prefect_worker_service_account_name}"
          }
        }
      }
    ]
  })
  managed_policy_arns = local.managed_policy_arns

  tags = var.tags
}

locals {
  prefect_worker_helmchart_values = var.create_prefect_kubernetes_worker ? [{
    name  = "serviceAccount.create"
    value = "true"
    type  = "auto"
    }, {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = "${aws_iam_role.prefect_worker_iam_role[0].arn}"
    type  = "auto"
    }, {
    name  = "serviceAccount.name"
    value = var.prefect_worker_service_account_name
    type  = "auto"
    }, {
    name  = "worker.apiConfig"
    value = "server"
    type  = "auto"
    }, {
    name  = "worker.config.workPool"
    value = "Kubernetes-workpool"
    type  = "auto"
    }, {
    name  = "worker.serverApiConfig.apiUrl"
    value = "http://prefect-server.${var.service_account_namespace}.svc.cluster.local:4200/api"
    type  = "auto"
  }] : []
}

module "prefect_worker_helmchart" {
  count = var.create_prefect_kubernetes_worker ? 1 : 0

  source = "../../../../../cloud/aws/helm_chart"

  name             = "prefect-worker"
  namespace        = var.service_account_namespace
  create_namespace = false
  repository       = "https://prefecthq.github.io/prefect-helm"
  chart            = "prefect-worker"
  chart_version    = var.prefect_chart_version
  values = templatefile("${path.module}/values.yaml", {
    prefect_deplyoment_type = "worker"
    nodeSelector            = jsonencode(var.nodeSelector)
    tolerations             = jsonencode(var.tolerations)
    affinity                = jsonencode(var.affinity)
    resources               = jsonencode(var.resources)
  })
  set        = local.prefect_worker_helmchart_values
  depends_on = [module.prefect_server_helmchart]
}


module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "prefect-secrets"
  secret_value = {
    db_instance_username = module.prefect_rds_backend.db_instance_username
    db_instance_password = module.prefect_rds_backend.db_instance_password
    db_instance_endpoint = module.prefect_rds_backend.db_instance_endpoint
    db_instance_name     = module.prefect_rds_backend.db_instance_name
  }
}
