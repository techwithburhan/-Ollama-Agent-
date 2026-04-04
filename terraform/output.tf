# # EC2 instance ID
# output "instance_id" {
#   description = "EC2 instance ID"
#   value       = aws_instance.advanced_ec2.id
# }

# # Static public IP (Elastic IP)
# output "elastic_ip" {
#   description = "Elastic IP address"
#   value       = aws_eip.ec2_eip.public_ip
# }

# # Private IP (internal use)
# output "private_ip" {
#   description = "Private IP of the instance"
#   value       = aws_instance.advanced_ec2.private_ip
# }

# # SSH connection command
# output "ssh_command" {
#   description = "Command to SSH into the instance"
#   value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_eip.ec2_eip.public_ip}"
# }

# EC2 instance IDs - one per instance
output "instance_ids" {
  description = "EC2 instance IDs"
  value       = { for k, v in aws_instance.advanced_ec2 : k => v.id }
}

# Elastic IPs - one per instance
output "elastic_ips" {
  description = "Elastic IP addresses"
  value       = { for k, v in aws_eip.ec2_eip : k => v.public_ip }
}

# Private IPs - one per instance
output "private_ips" {
  description = "Private IPs of all instances"
  value       = { for k, v in aws_instance.advanced_ec2 : k => v.private_ip }
}

# SSH commands - one per instance
output "ssh_commands" {
  description = "SSH commands for all instances"
  value       = { for k, v in aws_eip.ec2_eip : k => "ssh -i ~/.ssh/id_rsa ubuntu@${v.public_ip}" }
}