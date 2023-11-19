resource "random_password" "auth_key" {
  count = var.remote_tracking ? 1 : 0

  length           = 64
  special          = false
  override_special = "_%@"
}

module "lakefs_data_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.lakefs_data_bucket_name
  tags        = var.tags
}

# create rds instance
module "lakefs_rds_backend" {
  source     = "../../../../../cloud/aws/rds"
  create_rds = (var.remote_tracking && var.database_type == "postgres")

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block
  rds_instance_class   = var.rds_instance_class

  rds_identifier = "lakefs-backend"
  db_name        = "lakefsbackend"
  db_username    = "lakefs_backend_user"
  tags           = var.tags
}

resource "aws_iam_policy" "lakefs_s3_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
  name        = "LakeFSS3AccessPolicy"
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
}

resource "aws_iam_policy" "lakefs_dynamodb_iam_policy" {
  count       = (var.remote_tracking && var.database_type == "dynamodb") ? 1 : 0
  name        = "LakeFSDynamodbAccessPolicy"
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
        "Resource": "arn:aws:dynamodb:*:*:table/${var.dynamodb_table_name}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lakefs_ec2_iam_role" {
  count = var.remote_tracking ? 1 : 0
  name  = "EC2RoleForLakeFSWithS3Access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LakeFSRoleTrust",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  count      = var.remote_tracking ? 1 : 0
  role       = aws_iam_role.lakefs_ec2_iam_role[0].name
  policy_arn = aws_iam_policy.lakefs_s3_iam_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  count      = (var.remote_tracking && var.database_type == "dynamodb") ? 1 : 0
  role       = aws_iam_role.lakefs_ec2_iam_role[0].name
  policy_arn = aws_iam_policy.lakefs_dynamodb_iam_policy[0].arn
}

resource "aws_iam_instance_profile" "lakefs_instance_profile" {
  count = var.remote_tracking ? 1 : 0
  name  = "lakefs_instance_profile"
  role  = aws_iam_role.lakefs_ec2_iam_role[0].name
}

locals {
  lakefs_config_filename = var.remote_tracking && (var.database_type != null) ? "lakefs-${var.database_type}-config.tpl" : null
}

data "aws_region" "current" {}

module "lakefs" {
  source                  = "../../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "lakefs-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  ec2_instance_type       = var.ec2_instance_type
  iam_instance_profile    = var.remote_tracking ? aws_iam_instance_profile.lakefs_instance_profile[0].name : null
  enable_rds_ingress_rule = var.remote_tracking
  rds_type                = var.remote_tracking ? var.database_type : null

  ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
    lakefs_version = var.lakefs_version
    lakefs_config = var.database_type == "postgres" ? templatefile("${path.module}/${local.lakefs_config_filename}", {
      ec2_application_port = var.ec2_application_port
      db_instance_username = module.lakefs_rds_backend.db_instance_username
      db_instance_password = module.lakefs_rds_backend.db_instance_password
      db_instance_endpoint = module.lakefs_rds_backend.db_instance_endpoint
      db_instance_name     = module.lakefs_rds_backend.db_instance_name
      auth_secret_key      = resource.random_password.auth_key[0].result
      region               = data.aws_region.current.name
      }) : templatefile("${path.module}/${local.lakefs_config_filename}", {
      ec2_application_port = var.ec2_application_port
      auth_secret_key      = resource.random_password.auth_key[0].result
      dynamodb_table_name  = var.dynamodb_table_name
      region               = data.aws_region.current.name
    })
    }) : templatefile("${path.module}/simple-cloud-init.tpl", {
    ec2_application_port = var.ec2_application_port
  })

  tags       = var.tags
  depends_on = [module.lakefs_data_artifacts_bucket, module.lakefs_rds_backend]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "lakefs-secrets"
  secret_value = {
    db_instance_username      = module.lakefs_rds_backend.db_instance_username
    db_instance_password      = module.lakefs_rds_backend.db_instance_password
    db_instance_endpoint      = module.lakefs_rds_backend.db_instance_endpoint
    db_instance_name          = module.lakefs_rds_backend.db_instance_name
    auth_secret_key           = resource.random_password.auth_key[0].result
    bucket_id                 = module.lakefs_data_artifacts_bucket[0].bucket_id
    mlflow_server_dns_address = module.lakefs.public_dns
  }

  depends_on = [module.lakefs]
}
