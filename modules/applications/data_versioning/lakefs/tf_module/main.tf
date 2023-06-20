resource "random_password" "auth_key" {
  length           = 64
  special          = false
  override_special = "_%@"
}

module "lakefs_data_artifacts_bucket" {
  source = "../../../../cloud/aws/s3"
  count  = var.remote_tracking ? 1 : 0

  bucket_name = "ultimate-lakefs-data-artifacts-bucket"
  tags        = var.tags
}

# create rds instance
module "lakefs_rds_backend" {
  source = "../../../../cloud/aws/rds"

  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block
  rds_instance_class   = var.rds_instance_class

  rds_identifier = "lakefs-backend"
  db_name        = "lakefsbackend"
  db_username    = "lakefs_backend_user"
  tags           = var.tags
}

data "aws_region" "current" {}

locals {
  lakefs_config_filename = var.remote_tracking ? "simple-config.tpl" : "simple-config.tpl"
  lakefs_config = templatefile("${path.module}/${local.lakefs_config_filename}", {
    ec2_application_port = var.ec2_application_port
    db_instance_username = module.lakefs_rds_backend.db_instance_username
    db_instance_password = module.lakefs_rds_backend.db_instance_password
    db_instance_endpoint = module.lakefs_rds_backend.db_instance_endpoint
    db_instance_name     = module.lakefs_rds_backend.db_instance_name
    auth_secret_key      = resource.random_password.auth_key.result
    region               = data.aws_region.current.name
  })
}

module "lakefs" {
  source                  = "../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "lakefs-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  ec2_instance_type       = var.ec2_instance_type
  enable_rds_ingress_rule = var.remote_tracking
  rds_type                = var.database_type

  ec2_user_data = templatefile("${path.module}/cloud-init.tpl", {
    lakefs_version = var.lakefs_version
    lakefs_config  = local.lakefs_config
  })

  tags       = var.tags
  depends_on = [module.lakefs_data_artifacts_bucket, module.lakefs_rds_backend]
}
