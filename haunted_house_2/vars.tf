variable "boundary_bin" {
  default = "/usr/bin/boundary"
}

variable "boundary_key_name" {
  description = "Private key name on AWS"
  type        = string
  default    = "Boundary-2 EC2 machines access key"
}

variable "haunted_house_domain" {
  description = "Domain expected to exist on Route 53 in AWS"
  type        = string
  default     = "skeleton-key.nl"
}
