# # AWS provider - Ireland region
# # Fetch latest Ubuntu 22.04 AMI
# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
#   }
# }
 
# # SSH key pair
# resource "aws_key_pair" "deployer" {
#   key_name   = var.key_name
#   public_key = file("terraform.pub")
# }

# # Security group - allows SSH & HTTP in, all traffic out
# resource "aws_security_group" "ec2_sg" {
#   name        = "ec2-security-group"
#   description = "Allow SSH and HTTP"

#   ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
#   } 
#   ingress {
#     description = "Frontend Port"
#     from_port   = 3000
#     to_port     = 3000
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
#   }

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # EC2 instance - Ubuntu, t2.micro, with public IP
# resource "aws_instance" "advanced_ec2" {
#   ami                         = data.aws_ami.ubuntu.id
#   instance_type               = var.instance_type
#   key_name                    = aws_key_pair.deployer.key_name
#   vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
#   associate_public_ip_address = true

#   tags = {
#     Name = "Advanced-Ubuntu-EC2"
#   }
# }

# # Elastic IP - static public IP for the instance
# resource "aws_eip" "ec2_eip" {
#   instance = aws_instance.advanced_ec2.id
#   domain   = "vpc"
# }

# AWS provider - Ireland region
# Fetch latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# SSH key pair
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("terraform.pub")
}

# Security group - allows SSH & HTTP in, all traffic out
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-security-group"
  description = "Allow SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
  }

  ingress {
    description = "Frontend Port"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict in production
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ─── Locals ──────────────────────────────────────────────
locals {
  instances = {
    instance1 = { name = "instance1", instance_type = var.instance_type }
    instance2 = { name = "instance2", instance_type = var.instance_type }
    # 👆 Add or remove entries here to control how many EC2s are created
    # instance3 = { name = "instance3", instance_type = "t2.small" }  # can override type per instance too
  }
}

# EC2 instances - one per local.instances entry
resource "aws_instance" "advanced_ec2" {
  for_each = local.instances

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = each.value.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = each.value.name   # Tags each instance with its local key name
  }
}

# Elastic IPs - one per instance
resource "aws_eip" "ec2_eip" {
  for_each = local.instances

  instance = aws_instance.advanced_ec2[each.key].id
  domain   = "vpc"
}