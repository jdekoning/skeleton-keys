terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  profile = "playground"
}

variable github_repository {
  description = "Repository that needs aws access keys"
  type = string
}

variable github_token {
  description = "Token used to manage the github repository"
  type = string
  sensitive = true
}

provider "github" {
  token = var.github_token # Alternatively use GITHUB_TOKEN
}

data "aws_iam_group" "aws_admin" {
  group_name = "admins"
}

resource "aws_iam_user" "github_ci" {
  name = "github_ci_user"

  tags = {
    creator = "terraform"
    goal    = "kennissessie"
  }
}

resource "aws_iam_access_key" "github_ci" {
  user = aws_iam_user.github_ci.name
}

resource "aws_iam_group_membership" "github_admin" {
  name = "github_ci_as_admin"

  users = [
    aws_iam_user.github_ci.name,
  ]

  group = data.aws_iam_group.aws_admin.group_name
}

resource "github_actions_secret" "github-action-terraform-access-key" {
  repository       = var.github_repository
  secret_name      = "AWS_ACCESS_KEY_ID"
  plaintext_value  = aws_iam_access_key.github_ci.id
}

resource "github_actions_secret" "github-action-terraform-secret-key" {
  repository       = var.github_repository
  secret_name      = "AWS_SECRET_ACCESS_KEY"
  plaintext_value  = aws_iam_access_key.github_ci.secret
}
