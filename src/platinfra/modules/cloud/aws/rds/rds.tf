module "rds_security_group" {
  create  = var.create_rds
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "RDS_SG"
  description = "${var.rds_identifier} security group"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.rds_port
      to_port     = var.rds_port
      protocol    = "tcp"
      description = "${var.rds_identifier} access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    },
  ]

  tags = var.tags
}

# update module.rds version to 6.0
module "rds" {
  create_db_instance = var.create_rds
  source             = "terraform-aws-modules/rds/aws"
  # TODO: update provider version when this issue gets fixed
  # cannot update module version as it updates the aws provider version
  # which then breaks the aws kms and prevents the cluster to be created
  # see: # https://github.com/hashicorp/terraform-provider-aws/issues/34538
  # version            = "~> 6.3.0"
  version = "~> 5.0"

  identifier                     = "${var.rds_identifier}-default"
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = false

  # All available versions:
  # https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = var.rds_engine
  engine_version       = var.rds_engine_version
  family               = var.rds_family               # DB parameter group
  major_engine_version = var.rds_major_engine_version # DB option group
  instance_class       = var.rds_instance_class
  skip_final_snapshot  = var.skip_final_snapshot

  allocated_storage = var.allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = var.db_name
  username = var.db_username
  port     = var.rds_port

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [module.rds_security_group.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = var.backup_retention_period

  tags = var.tags
}
