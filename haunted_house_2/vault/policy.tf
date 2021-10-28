resource "vault_policy" "boundary" {
  name = "boundary"

  policy = <<EOT
# Allow Boundary to read and verify the properties of the token. This is
# provided by the "default" policy.
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow Boundary to renew the token. This is provided by the "default"
# policy.
path "auth/token/renew-self" {
  capabilities = ["update"]
}

# Allow Boundary to revoke the token when the credential store is updated
# to use a new token or the credential store is deleted. This is provided
# by the "default" policy.
path "auth/token/revoke-self" {
  capabilities = ["update"]
}

# Allow Boundary to renew the credentials in active sessions. This is
# provided by the "default" policy.
path "sys/leases/renew" {
  capabilities = ["update"]
}

# Allow Boundary to revoke the credentials issued for a session when the
# session is terminated.
path "sys/leases/revoke" {
  capabilities = ["update"]
}

# Allow Boundary to read and verify the token's capabilities for each Vault
# path used by the credential store. This is provided by the "default"
# policy.
path "sys/capabilities-self" {
  capabilities = ["update"]
}

path "secret/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOT
}

resource "vault_policy" "admin" {
  name = "admin"

  policy = <<EOT
path "/*" {
  capabilities = ["create", "read", "delete", "update", "list"]
}
EOT
}