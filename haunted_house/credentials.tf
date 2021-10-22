resource "tls_private_key" "boundary_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.boundary_key_name
  public_key = tls_private_key.boundary_ssh.public_key_openssh
}

resource "tls_private_key" "boundary_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "boundary_ca_cert" {
  key_algorithm     = tls_private_key.boundary_ca.algorithm
  private_key_pem   = tls_private_key.boundary_ca.private_key_pem
  is_ca_certificate = true

  subject {
    common_name  = "controller.${data.aws_route53_zone.skeleton_key.name}"
    organization = "Halloween crazyness"
  }

  validity_period_hours = 24

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
}

resource "tls_private_key" "api_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "api_csr" {
  key_algorithm   = tls_private_key.api_key.algorithm
  private_key_pem = tls_private_key.api_key.private_key_pem

  subject {
    common_name  = "controller.${data.aws_route53_zone.skeleton_key.name}"
    organization = "Halloween crazyness"
  }
}

resource "tls_locally_signed_cert" "api_crt" {
  cert_request_pem = tls_cert_request.api_csr.cert_request_pem

  ca_key_algorithm   = tls_private_key.boundary_ca.algorithm
  ca_private_key_pem = tls_private_key.boundary_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.boundary_ca_cert.cert_pem

  validity_period_hours = 24
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "tls_private_key" "postgresql_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "postgresql_csr" {
  key_algorithm   = tls_private_key.postgresql_key.algorithm
  private_key_pem = tls_private_key.postgresql_key.private_key_pem

  dns_names = ["localhost"]

  subject {
    common_name  = "postgresql.${data.aws_route53_zone.skeleton_key.name}"
    organization = "Halloween crazyness"
  }
}

resource "tls_locally_signed_cert" "postgresql_crt" {
  cert_request_pem = tls_cert_request.postgresql_csr.cert_request_pem

  ca_key_algorithm   = tls_private_key.boundary_ca.algorithm
  ca_private_key_pem = tls_private_key.boundary_ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.boundary_ca_cert.cert_pem

  validity_period_hours = 24
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

# Hacky stupidness, whatever
resource "local_file" "boundary_controller_key" {
  content         = tls_private_key.api_key.private_key_pem
  filename        = "../secrets/boundary-controller.key"
  file_permission = "0600"
}

resource "local_file" "boundary_controller_crt" {
  content         = tls_locally_signed_cert.api_crt.cert_pem
  filename        = "../secrets/boundary-controller.crt"
  file_permission = "0600"
}

resource "local_file" "boundary_postgresql_key" {
  content         = tls_private_key.postgresql_key.private_key_pem
  filename        = "../secrets/boundary-postgresql.key"
  file_permission = "0600"
}

resource "local_file" "boundary_postgresql_crt" {
  content         = tls_locally_signed_cert.postgresql_crt.cert_pem
  filename        = "../secrets/boundary-postgresql.crt"
  file_permission = "0600"
}
