output "secret" {
  value     = var.json_secret ? jsondecode(aws_secretsmanager_secret_version.secretsmanager_secret_version.secret_string) : aws_secretsmanager_secret_version.secretsmanager_secret_version.secret_string
  sensitive = true
}
