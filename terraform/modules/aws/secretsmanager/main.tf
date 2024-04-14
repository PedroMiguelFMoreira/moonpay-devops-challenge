resource "aws_secretsmanager_secret" "secret" {
  name        = var.name
  description = var.description
  tags = merge(
    { managed_by = "terraform" },
    var.tags
  )
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = jsonencode(var.secret)
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }
}