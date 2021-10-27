resource "random_pet" "test" {
  length = 1
}

locals {
  pub_cidrs  = cidrsubnets("10.0.0.0/24", 4, 4, 4, 4)
  priv_cidrs = cidrsubnets("10.0.100.0/24", 4, 4, 4, 4)
}

variable "tag" {
  default = "boundary-test"
}

variable "boundary_bin" {
  default = "~/projects/boundary/bin"
}

variable "boundary_key_name" {
  default = ""
}

variable "num_workers" {
  default = 1
}

variable "num_controllers" {
  default = 2
}

variable "num_targets" {
  default = 1
}

variable "num_subnets_public" {
  default = 2
}

variable "num_subnets_private" {
  default = 2
}

variable "tls_cert_path" {
  default = "/etc/pki/tls/boundary/boundary.cert"
}

variable "tls_key_path" {
  default = "/etc/pki/tls/boundary/boundary.key"
}

variable "tls_disabled" {
  default = true
}

variable "kms_type" {
  default = "aws"
}

variable "haunted_house_domain" {
  description = "Domain expected to exist on Route 53 in AWS"
  type        = string
  default     = ""
}
