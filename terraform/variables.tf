# AWS region
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Key pair name
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "terraform-key"
}
