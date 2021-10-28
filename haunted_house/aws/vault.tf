resource "aws_instance" "vault" {
  count                       = var.num_vaults
  ami                         = "ami-0fd4a654080984493"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.*.id[count.index]
  key_name                    = aws_key_pair.boundary_ssh.key_name
  vpc_security_group_ids      = [aws_security_group.vault.id]
  associate_public_ip_address = true

  provisioner "file" {
    source      = "${path.module}/install/install_vault.sh"
    destination = "~/install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0755 ~/install.sh",
      "sudo ~/./install.sh"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.boundary_ssh.private_key_pem
    host        = self.public_ip
  }
}

resource "aws_security_group" "vault" {
  name_prefix = "vault"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_8200_controller_lb" {
  type                     = "ingress"
  from_port                = 8200
  to_port                  = 8200
  protocol                 = "tcp"
  security_group_id        = aws_security_group.vault.id
  source_security_group_id = aws_security_group.controller_lb.id
}

resource "aws_security_group_rule" "allow_ssh_vault" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vault.id
}

resource "aws_security_group_rule" "allow_egress_vault" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vault.id
}
