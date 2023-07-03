module "prefect" {
  source                  = "../../../../cloud/aws/ec2"
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

  ec2_user_data = templatefile("${path.module}/simple-cloud-init.tpl", {
    prefect_version      = var.prefect_version
    ec2_application_port = var.ec2_application_port
  })
}
