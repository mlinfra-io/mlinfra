resource "aws_secretsmanager_secret" "secretsmanager_secret" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "secretsmanager_secret_version" {
  secret_id     = aws_secretsmanager_secret.secretsmanager_secret.id
  secret_string = jsonencode(var.secret_value)
}
