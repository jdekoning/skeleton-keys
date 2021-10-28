output "boundary_ip" {
  value = aws_instance.boundary_controller.public_ip
}

output "boundary_ipv6" {
  value = aws_instance.boundary_controller.ipv6_addresses
}
