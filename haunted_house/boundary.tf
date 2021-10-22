resource "aws_instance" "boundary_controller" {
  ami                         = data.aws_ami.ubuntu.image_id
  key_name                    = aws_key_pair.generated_key.key_name
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.boundary[0].id
  associate_public_ip_address = true
  ipv6_address_count          = 1
  vpc_security_group_ids      = [aws_security_group.boundary-ssh.id]
  depends_on                  = [aws_internet_gateway.boundary]

  root_block_device {
    volume_size = 50
  }
}

resource "null_resource" "install_boundary_machine" {
  depends_on = [
    aws_instance.boundary_controller,
    local_file.boundary_postgresql_crt,
    local_file.boundary_postgresql_key,
  ]

  triggers = {
    instance       = aws_instance.boundary_controller.id
    general_script = md5(file("scripts/prepare_instance.sh"))
  }

  connection {
    host        = aws_instance.boundary_controller.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.boundary_ssh.private_key_pem
    agent       = "false"
    timeout     = "3m"
  }

  provisioner "file" {
    source      = "../secrets/boundary-postgresql.key"
    destination = "/tmp/boundary-postgresql.key"
  }

  provisioner "file" {
    source      = "../secrets/boundary-postgresql.crt"
    destination = "/tmp/boundary-postgresql.crt"
  }

  provisioner "remote-exec" {
    script = "scripts/prepare_instance.sh"
  }

  provisioner "remote-exec" {
    script = "scripts/start_postgresql.sh"
  }

}

resource "null_resource" "install_boundary_controller" {
  depends_on = [
    null_resource.install_boundary_machine,
    local_file.boundary_controller_crt,
    local_file.boundary_controller_key,
  ]

  triggers = {
    config          = md5(file("scripts/boundary-controller.hcl"))
    boundary_script = md5(file("scripts/setup_boundary.sh"))
  }

  connection {
    host        = aws_instance.boundary_controller.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.boundary_ssh.private_key_pem
    agent       = "false"
    timeout     = "3m"
  }

  provisioner "file" {
    source      = "scripts/boundary-controller.hcl"
    destination = "/tmp/boundary-controller.hcl"
  }

  provisioner "file" {
    source      = "../secrets/boundary-controller.key"
    destination = "/tmp/boundary-controller.key"
  }

  provisioner "file" {
    source      = "../secrets/boundary-controller.crt"
    destination = "/tmp/boundary-controller.crt"
  }

  provisioner "remote-exec" {
    script = "scripts/setup_boundary.sh"
  }

}
