# EC2 instance ID
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.advanced_ec2.id
}

# Static public IP (Elastic IP)
output "elastic_ip" {
  description = "Elastic IP address"
  value       = aws_eip.ec2_eip.public_ip
}

# Private IP (internal use)
output "private_ip" {
  description = "Private IP of the instance"
  value       = aws_instance.advanced_ec2.private_ip
}

# SSH connection command
output "ssh_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.ec2_eip.public_ip}"
}
