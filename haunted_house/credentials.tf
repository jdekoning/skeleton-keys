resource "tls_private_key" "boundary" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.boundary_key_name
  public_key = tls_private_key.boundary.public_key_openssh
}
