sudo cat << EOF > /etc/vault.d/vault.hcl
listener "tcp" {
  address       = "0.0.0.0:8200"
  tls_disable   = 1
}

storage "file" {
  path = "/opt/vault/data"
}

ui = true
EOF

sudo service vault restart
