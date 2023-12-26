resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  name_prefix = var.secret_name
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id     = aws_secretsmanager_secret.secretsmanager_secret.id
  secret_string = jsonencode(var.secret_value)
}
