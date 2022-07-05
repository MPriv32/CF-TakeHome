output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "key_name" {
  value = var.key_name
}

output "bastion_ssh_key" {
  value = aws_key_pair.bastion_auth.id
}