locals {
  common_ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Access allowed from anywhere"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS Access allowed from anywhere"
      cidr_blocks = [var.vpc_cidr_block]
    },
    {
      from_port   = var.ec2_application_port
      to_port     = var.ec2_application_port
      protocol    = "tcp"
      description = "HTTP Access to the application allowed from anywhere"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Application can access anything on internet"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  rds_postgres_ingress_rules = [{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    description = "Allow Postgres RDS access from within VPC"
    cidr_blocks = [var.vpc_cidr_block]
  }]

  rds_mysql_ingress_rules = [{
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    description = "Allow MySQL RDS access from within VPC"
    cidr_blocks = [var.vpc_cidr_block]
  }]

  _ingress_rules = var.enable_rds_ingress_rule ? (var.rds_type == "postgres" ? concat(local.common_ingress_rules, local.rds_postgres_ingress_rules) : concat(local.common_ingress_rules, local.rds_mysql_ingress_rules)) : local.common_ingress_rules
  ingress_rules  = var.additional_ingress_rules != null ? concat(local._ingress_rules, var.additional_ingress_rules) : local._ingress_rules
}
