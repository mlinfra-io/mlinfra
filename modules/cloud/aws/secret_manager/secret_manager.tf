resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  name = var.secret_name
}

locals {
  secret_value = var.json_secret ? jsondecode(var.secret_value) : var.secret_value
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id     = aws_secretsmanager_secret.secretsmanager_secret.id
  secret_string = local.secret_value
}
