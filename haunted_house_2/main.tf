terraform {
  backend "s3" {
    profile    = "playground"
    bucket     = "haunted-house-skeletons"
    key        = "core/terraform.tfstate"
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

output "kms_recovery_key" {
  value = module.aws.kms_recovery_key_id
}

module "boundary" {
  source              = "./boundary"
  url                 = "http://${module.aws.boundary_lb}:9200"
  target_ips          = module.aws.target_ips
  kms_recovery_key_id = module.aws.kms_recovery_key_id
}
