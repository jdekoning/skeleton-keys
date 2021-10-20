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

resource "null_resource" "run_boundary_fake" {
  depends_on = [
    aws_instance.boundary_controller
  ]

  triggers = {
    config          = md5(file("scripts/boundary-controller.hcl"))
    general_script  = md5(file("scripts/prepare_instance.sh"))
    boundary_script = md5(file("scripts/setup_boundary.sh"))
  }

  connection {
    host        = aws_instance.boundary_controller.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.boundary.private_key_pem
    agent       = "false"
    timeout     = "3m"
  }

  provisioner "file" {
    source      = "scripts/boundary-controller.hcl"
    destination = "/etc/boundary-controller.hcl"
  }

  provisioner "remote-exec" {
    script = "scripts/prepare_instance.sh"
  }
}
