# TODO: Replace with module from Anton Babenko
resource "aws_s3_bucket" "wandb_artifacts_bucket" {
  count  = var.remote_tracking ? 1 : 0
  bucket = "ultimate-wandb-artifacts-storage-bucket"
  tags   = var.tags
}

resource "aws_iam_policy" "s3_access_iam_policy" {
  name        = "S3AccessPolicy"
  description = "Allows access to S3 bucket"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.wandb_artifacts_bucket[0].arn}",
        "${aws_s3_bucket.wandb_artifacts_bucket[0].arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_iam_role" {
  name = "EC2RoleWithS3Access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_access_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.s3_access_iam_policy.arn
}

resource "aws_iam_instance_profile" "wandb_instance_profile" {
  name = "wandb_instance_profile"
  role = aws_iam_role.ec2_iam_role.name
}

# create rds instance
module "wandb_rds_backend" {
  source = "../../../../cloud/aws/rds"

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block

  create_rds               = var.remote_tracking
  rds_engine               = "mysql"
  rds_engine_version       = "8.0"
  rds_family               = "mysql8.0" # DB parameter group
  rds_major_engine_version = "8.0"      # DB option group
  rds_port                 = 3306

  rds_identifier = "wandb-backend"
  db_name        = "wandbbackend"
  db_username    = "wandb_backend_user"
  tags           = var.tags
}

data "aws_region" "current" {}

module "wandb" {
  source                  = "../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "wandb-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  iam_instance_profile    = var.remote_tracking ? aws_iam_instance_profile.wandb_instance_profile.name : null
  enable_rds_ingress_rule = var.remote_tracking

  ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
    wandb_version        = var.wandb_version
    ec2_application_port = var.ec2_application_port
    aws_region           = data.aws_region.current.name
    db_instance_username = module.wandb_rds_backend.db_instance_username
    db_instance_password = module.wandb_rds_backend.db_instance_password
    db_instance_endpoint = module.wandb_rds_backend.db_instance_endpoint
    db_instance_name     = module.wandb_rds_backend.db_instance_name
    bucket_id            = aws_s3_bucket.wandb_artifacts_bucket[0].id
    }) : templatefile("${path.module}/simple-cloud-init.tpl", {
    wandb_version        = var.wandb_version
    ec2_application_port = var.ec2_application_port
  })

  depends_on = [resource.aws_s3_bucket.wandb_artifacts_bucket, module.wandb_rds_backend]
}
