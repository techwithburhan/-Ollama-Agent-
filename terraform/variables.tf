# # AWS region
# variable "aws_region" {
#   description = "AWS deployment region"
#   type        = string
#   default     = "eu-west-1"
# }

# # EC2 instance type
# variable "instance_type" {
#   description = "EC2 instance type"
#   type        = string
#   default     = "t2.micro"
# }

# # Key pair name
# variable "key_name" {
#   description = "Name of the SSH key pair"
#   type        = string
#   default     = "terraform-key"
# }

# AWS region
variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"
}

# EC2 instance type (default for all instances unless overridden in locals)
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