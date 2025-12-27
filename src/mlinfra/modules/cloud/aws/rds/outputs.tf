output "db_instance_username" {
  value = module.rds.db_instance_username
}

output "db_instance_password" {
  value     = var.create_rds ? jsondecode(data.aws_secretsmanager_secret_version.db_password[0].secret_string)["password"] : null
  sensitive = true
}

output "db_instance_password_arn" {
  value = module.rds.db_instance_master_user_secret_arn
}

output "db_instance_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "db_instance_name" {
  value = module.rds.db_instance_name
}

output "db_instance_arn" {
  value = module.rds.db_instance_arn
}
