variable "aws_bucket" {
  description = "Bucket to store haunted house stuff in"
  type        = string
}

resource "aws_kms_key" "boundary_state" {
  description             = "KMS key boundary state"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "boundary_state" {
  name          = "alias/boundary_state-key"
  target_key_id = aws_kms_key.boundary_state.key_id
}

resource "aws_s3_bucket" "bdr-model-versioning" {
  bucket = var.aws_bucket

  versioning {
    enabled = true
  }

  force_destroy = true
}

data "aws_iam_policy" "aws_admin" {
  name = "AdministratorAccess"
}

resource "aws_iam_user" "github_ci" {
  name = "github_ci_user"
}

resource "aws_iam_access_key" "github_ci" {
  user = aws_iam_user.github_ci.name
}

resource "aws_iam_user_policy_attachment" "github_admin" {
  user       = aws_iam_user.github_ci.name
  policy_arn = data.aws_iam_policy.aws_admin.arn
}
