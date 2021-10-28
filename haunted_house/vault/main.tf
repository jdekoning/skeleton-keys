terraform {
  required_providers {
    vaultoperator = {
      source = "rickardgranberg/vaultoperator"
      version = "0.1.2"
    }
    vault = {
      source = "hashicorp/vault"
      version = "2.24.1"
    }
  }
}

provider "vaultoperator" {
  vault_url = var.vault_url
}

resource "vaultoperator_init" "boundary" {
  secret_shares    = 5
  secret_threshold = 3
}

data "template_file" "vault_server_unseal_config_template" {
  template = file("${path.module}/scripts/vault_server_unseal_config.script.sh.tmpl")

  vars = {
    vault_unseal_key_1 = tolist(vaultoperator_init.boundary.keys)[0]
    vault_unseal_key_2 = tolist(vaultoperator_init.boundary.keys)[1]
    vault_unseal_key_3 = tolist(vaultoperator_init.boundary.keys)[2]
  }
}

resource "null_resource" "unseal_vault_machines" {
  count = length(var.vault_ips)

  connection {
    type = "ssh"
    host = var.vault_ips[count.index]
    user = "ubuntu"
    private_key = var.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      data.template_file.vault_server_unseal_config_template.rendered,
    ]
  }
}

provider "vault" {
  token = vaultoperator_init.boundary.root_token
  address = var.vault_url
}

resource "vault_token" "boundary" {
  no_parent = true
  policies = [vault_policy.boundary.name]
  renewable = true
  ttl = "24h"
  period = "24h"
}
