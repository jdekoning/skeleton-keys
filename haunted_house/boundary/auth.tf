resource "boundary_auth_method" "password" {
  name        = "corp_password_auth_method"
  description = "Password auth is the best for hackers"
  type        = "password"
  scope_id    = boundary_scope.org.id
}
