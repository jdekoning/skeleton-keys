variable "boundary_key_name" {
  description = "Private key name on AWS"
  type        = string
}

variable "haunted_house_domain" {
  description = "Domain expected to exist on Route 53 in AWS"
  type        = string
}

variable "boundary_controller_port" {
  description = "The port the Boundary Controller listens on"
  type        = number
  default     = 8080
}

variable "boundary_path_pattern" {
  description = "The path-pattern on which Boundary will react through the loadbalancer"
  type        = string
  default     = "/serve/*"
}

variable "boundary_worker_port" {
  description = "The port the Boundary Worker listens on"
  type        = number
  default     = 8081
}