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
  source              = "./boundary"
  url                 = "https://${var.haunted_house_domain}"
  target_ips          = module.aws.target_ips
  kms_recovery_key_id = module.aws.kms_recovery_key_id
}
