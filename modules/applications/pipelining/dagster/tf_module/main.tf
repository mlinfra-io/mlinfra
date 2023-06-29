
module "dagster" {
  source                  = "../../../../cloud/aws/ec2"
  vpc_id                  = var.vpc_id
  default_vpc_sg          = var.default_vpc_sg
  vpc_cidr_block          = var.vpc_cidr_block
  ec2_subnet_id           = var.subnet_id
  ec2_instance_name       = "dagster-server"
  ec2_spot_instance       = var.ec2_spot_instance
  ec2_application_port    = var.ec2_application_port
  ec2_instance_type       = var.ec2_instance_type
  enable_rds_ingress_rule = var.remote_tracking

  # ec2_user_data = var.remote_tracking ? templatefile("${path.module}/remote-cloud-init.tpl", {
  #   mlflow_version       = var.mlflow_version
  #   ec2_application_port = var.ec2_application_port
  #   db_instance_username = module.mlflow_rds_backend.db_instance_username
  #   db_instance_password = module.mlflow_rds_backend.db_instance_password
  #   db_instance_endpoint = module.mlflow_rds_backend.db_instance_endpoint
  #   db_instance_name     = module.mlflow_rds_backend.db_instance_name
  #   bucket_id            = module.mlflow_artifacts_bucket[0].bucket_id
  #   }) : templatefile("${path.module}/simple-cloud-init.tpl", {
  #   mlflow_version       = var.mlflow_version
  #   ec2_application_port = var.ec2_application_port
  # })

  ec2_user_data = templatefile("${path.module}/simple-cloud-init.tpl", {
    dagster_version      = var.dagster_version
    dagit_version        = var.dagit_version
    ec2_application_port = var.ec2_application_port
  })
}
