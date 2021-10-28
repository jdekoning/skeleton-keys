resource "vault_mount" "enable_kv" {
  path = "secret"
  type = "kv"
  options = {
    "version" = "2"
  }
}

resource "vault_generic_secret" "something_random" {
  depends_on = [
    vault_mount.enable_kv
  ]
  path = "secret/boohoo"
  data_json = <<EOT
{
  "one": "not so secret",
  "two": "whatever"
}
EOT

}
