terraform {
  backend "s3" {
    bucket     = "haunted-house-skeletons"
    key        = "core-reference/terraform.tfstate"
    region     = "eu-west-1"
    kms_key_id = "alias/boundary_state-key"
  }
}

module "aws" {
  source               = "./aws"
  boundary_bin         = var.boundary_bin
  boundary_key_name    = var.boundary_key_name
  haunted_house_domain = var.haunted_house_domain
}

module "boundary" {
  source               = "./boundary"
  boundary_url         = "https://boundary.${var.haunted_house_domain}"
  vault_url            = "https://vault.${var.haunted_house_domain}"
  target_ips           = module.aws.target_ips
  kms_recovery_key_id  = module.aws.kms_recovery_key_id
  vault_boundary_token = module.vault.vault_boundary_token
}

module "vault" {
  source               = "./vault"
  vault_url            = "https://vault.${var.haunted_house_domain}"
  vault_ips            = module.aws.vault_ips
  private_key_pem      = module.aws.private_key
  vault_admin_password = var.vault_admin_password
}
