resource "vault_mount" "enable_pki" {
  path = "pki_int"
  type = "pki"
  default_lease_ttl_seconds = 259200
  # 3 days
  max_lease_ttl_seconds = 31536000
  # 1 year
}

resource "vault_generic_endpoint" "pki_int_tidy" {
  depends_on = [
    vault_mount.enable_pki
  ]
  path = "pki_int/tidy"
  disable_read = true
  disable_delete = true
  data_json = <<EOT
{"tidy_cert_store":true,"tidy_revoked_certs": true,"safety_buffer":"72h"}
EOT

}

resource "vault_mount" "ssh-mount" {
  path = "ssh"
  type = "ssh"
  description = "The SSH backend for remote machine acces"
}

resource "vault_ssh_secret_backend_ca" "ssh-ca" {
  backend = vault_mount.ssh-mount.path
  generate_signing_key = true
}

resource "vault_ssh_secret_backend_role" "ssh-ca-role" {
  name = "ca-role"
  backend = vault_mount.ssh-mount.path
  key_type = "ca"
  allow_user_certificates = true
  allowed_users = "ubuntu"
  default_extensions = {
    permit-pty = ""
  }
}
