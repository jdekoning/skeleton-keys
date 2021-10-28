variable "boundary_url" {
  default = "http://127.0.0.1:9200"
}

variable "vault_url" {
  default = "http://127.0.0.1:8200"
}

variable "backend_team" {
  type = set(string)
  default = [
    "jim",
    "mike",
    "todd",
  ]
}

variable "frontend_team" {
  type = set(string)
  default = [
    "randy",
    "susmitha",
  ]
}

variable "leadership_team" {
  type = set(string)
  default = [
    "jeff",
    "pete",
    "jonathan",
    "malnick"
  ]
}

variable "target_ips" {
  type    = set(string)
  default = []
}

variable "kms_recovery_key_id" {
  default = ""
}

variable "vault_boundary_token" {}
