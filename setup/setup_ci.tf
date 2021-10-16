variable "github_repository" {
  description = "Repository that needs aws access keys"
  type        = string
}

variable "github_token" {
  description = "Token used to manage the github repository"
  type        = string
  sensitive   = true
}

resource "github_actions_secret" "github-action-terraform-access-key" {
  repository      = var.github_repository
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.github_ci.id
}

resource "github_actions_secret" "github-action-terraform-secret-key" {
  repository      = var.github_repository
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = aws_iam_access_key.github_ci.secret
}
