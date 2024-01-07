module "wandb_artifacts_bucket" {
  source = "../../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = var.wandb_artifacts_bucket_name
  tags        = var.tags
}

resource "random_pet" "file_storage" {
  length = 2
}

resource "aws_sqs_queue" "file_storage" {
  count = var.remote_tracking ? 1 : 0
  name  = "wandb-file-storage-${random_pet.file_storage.id}"

  # Enable long-polling
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_policy" "file_storage" {
  count = var.remote_tracking ? 1 : 0

  queue_url = aws_sqs_queue.file_storage.0.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : ["sqs:SendMessage"],
        "Resource" : "arn:aws:sqs:*:*:${aws_sqs_queue.file_storage.0.name}",
        "Condition" : {
          "ArnEquals" : { "aws:SourceArn" : "${module.wandb_artifacts_bucket[0].bucket_arn}" }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_notification" "file_storage" {
  count = var.remote_tracking ? 1 : 0

  depends_on = [aws_sqs_queue_policy.file_storage]

  bucket = module.wandb_artifacts_bucket[0].bucket_id

  queue {
    queue_arn = aws_sqs_queue.file_storage.0.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_iam_policy" "s3_access_iam_policy" {
  count       = var.remote_tracking ? 1 : 0
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
        "${module.wandb_artifacts_bucket[0].bucket_arn}",
        "${module.wandb_artifacts_bucket[0].bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "ec2_iam_role" {
  count = var.remote_tracking ? 1 : 0
  name  = "EC2RoleWithS3Access"

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
  count      = var.remote_tracking ? 1 : 0
  role       = aws_iam_role.ec2_iam_role[0].name
  policy_arn = aws_iam_policy.s3_access_iam_policy[0].arn
}

resource "aws_iam_instance_profile" "wandb_instance_profile" {
  count = var.remote_tracking ? 1 : 0
  name  = "wandb_instance_profile"
  role  = aws_iam_role.ec2_iam_role[0].name
}

# create rds instance
module "wandb_rds_backend" {
  source = "../../../../../cloud/aws/rds"

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block

  create_rds               = var.remote_tracking
  rds_engine               = "mysql"
  rds_engine_version       = "8.0"
  rds_family               = "mysql8.0" # DB parameter group
  rds_major_engine_version = "8.0"      # DB option group
  rds_port                 = 3306
  rds_instance_class       = var.rds_instance_class


  rds_identifier = "wandb-backend"
  db_name        = "wandbbackend"
  db_username    = "wandb_backend_user"
  tags           = var.tags
}

data "aws_region" "current" {}

module "wandb" {
  source                  = "../../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "wandb-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  iam_instance_profile    = var.remote_tracking ? aws_iam_instance_profile.wandb_instance_profile[0].name : null
  ec2_instance_type       = var.ec2_instance_type
  enable_rds_ingress_rule = var.remote_tracking
  rds_type                = "mysql"

  ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
    wandb_version        = var.wandb_version
    ec2_application_port = var.ec2_application_port
    aws_region           = data.aws_region.current.name
    bucket_queue         = aws_sqs_queue.file_storage[0].url
    db_instance_username = module.wandb_rds_backend.db_instance_username
    db_instance_password = module.wandb_rds_backend.db_instance_password
    db_instance_endpoint = module.wandb_rds_backend.db_instance_endpoint
    db_instance_name     = module.wandb_rds_backend.db_instance_name
    bucket_id            = module.wandb_artifacts_bucket[0].bucket_id
    }) : templatefile("${path.module}/simple-cloud-init.tpl", {
    wandb_version        = var.wandb_version
    ec2_application_port = var.ec2_application_port
  })

  depends_on = [module.wandb_artifacts_bucket, module.wandb_rds_backend]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "wandb-secrets"
  secret_value = {
    db_instance_username      = module.wandb_rds_backend.db_instance_username
    db_instance_password      = module.wandb_rds_backend.db_instance_password
    db_instance_endpoint      = module.wandb_rds_backend.db_instance_endpoint
    db_instance_name          = module.wandb_rds_backend.db_instance_name
    bucket_id                 = module.wandb_artifacts_bucket[0].bucket_id
    mlflow_server_dns_address = module.wandb.public_dns
  }

  depends_on = [module.wandb]
}
