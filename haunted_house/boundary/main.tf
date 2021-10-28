terraform {
  required_providers {
    boundary = {
      source  = "hashicorp/boundary"
      version = "1.0.5"
    }
  }
}

provider "boundary" {
  addr             = var.boundary_url
  recovery_kms_hcl = <<EOT
kms "awskms" {
    purpose    = "recovery"
    shared_creds_profile = "playground"
    region     = "eu-west-1"
    key_id     = "global_root"
    kms_key_id = "${var.kms_recovery_key_id}"
}
EOT
}
