output "secret" {
  value     = jsondecode(aws_secretsmanager_secret_version.secretsmanager_secret_version.secret_string)
  sensitive = true
}
