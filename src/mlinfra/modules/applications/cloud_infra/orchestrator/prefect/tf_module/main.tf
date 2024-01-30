# create rds instance
module "prefect_rds_backend" {
  source = "../../../../../cloud/aws/rds"

  create_rds = var.remote_tracking

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  vpc_cidr_block       = var.vpc_cidr_block
  rds_instance_class   = var.rds_instance_class

  rds_identifier = "prefect-backend"
  db_name        = "prefectbackend"
  db_username    = "prefect_backend_user"
  tags           = var.tags
}

module "prefect" {
  source                  = "../../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "prefect-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  ec2_instance_type       = var.ec2_instance_type
  enable_rds_ingress_rule = var.remote_tracking
  additional_ingress_rules = [{
    from_port   = 4200
    to_port     = 4200
    protocol    = "tcp"
    description = "Allowing application port 4200 access"
    cidr_blocks = ["0.0.0.0/0"]
  }]

  ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
    prefect_version      = var.prefect_version
    ec2_application_port = var.ec2_application_port
    db_instance_username = module.prefect_rds_backend.db_instance_username
    db_instance_password = module.prefect_rds_backend.db_instance_password
    db_instance_endpoint = module.prefect_rds_backend.db_instance_endpoint
    db_instance_name     = module.prefect_rds_backend.db_instance_name
    }) : templatefile("${path.module}/simple-cloud-init.tpl", {
    prefect_version      = var.prefect_version
    ec2_application_port = var.ec2_application_port
  })

  depends_on = [module.prefect_rds_backend]
}

module "secrets_manager" {
  source = "../../../../../cloud/aws/secrets_manager"
  count  = var.remote_tracking ? 1 : 0

  secret_name = "prefect-secrets"
  secret_value = {
    db_instance_username       = module.prefect_rds_backend.db_instance_username
    db_instance_password       = module.prefect_rds_backend.db_instance_password
    db_instance_endpoint       = module.prefect_rds_backend.db_instance_endpoint
    db_instance_name           = module.prefect_rds_backend.db_instance_name
    prefect_server_dns_address = module.prefect.public_dns
  }

  depends_on = [module.prefect]
}
