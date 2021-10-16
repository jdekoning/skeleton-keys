variable "aws_bucket" {
  description = "Bucket to store haunted house stuff in"
  type        = string
}

resource "aws_s3_bucket" "bdr-model-versioning" {
  bucket = var.aws_bucket

  versioning {
    enabled = true
  }

  force_destroy = true

  tags = {
    creator = "terraform"
    goal    = "haunted_house"
  }
}

data "aws_iam_policy" "aws_admin" {
  name = "AdministratorAccess"
}

resource "aws_iam_user" "github_ci" {
  name = "github_ci_user"

  tags = {
    creator = "terraform"
    goal    = "haunted_house"
  }
}

resource "aws_iam_access_key" "github_ci" {
  user = aws_iam_user.github_ci.name
}

resource "aws_iam_user_policy_attachment" "github_admin" {
  user       = aws_iam_user.github_ci.name
  policy_arn = data.aws_iam_policy.aws_admin.arn
}
