output "boundary_lb" {
  value = aws_lb.controller.dns_name
}

output "target_ips" {
  value = aws_instance.target.*.private_ip
}

output "vault_ips" {
  value = aws_instance.vault.*.public_ip
}

output "kms_recovery_key_id" {
  value = aws_kms_key.recovery.id
}

output "private_key" {
  value = tls_private_key.boundary_ssh.private_key_pem
}
