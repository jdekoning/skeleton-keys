resource "boundary_credential_store_vault" "vault" {
  name        = "Root"
  description = "My Boundary Vault credential store!"
  address     = var.vault_url
  token       = var.vault_boundary_token
  scope_id    = boundary_scope.core_infra.id
}

resource "boundary_credential_library_vault" "vault" {
  name                = "Bohoo"
  description         = "My Boundary Vault credential library!"
  credential_store_id = boundary_credential_store_vault.vault.id
  path                = "secret/data/boohoo" # change to Vault backend path
  http_method         = "GET"
}