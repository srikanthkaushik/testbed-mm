variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "ssh_allowed_cidr" {
  description = "Your IP address in CIDR notation — only this IP can SSH into the EC2 instance (e.g. '203.0.113.5/32'). Find yours at https://checkip.amazonaws.com"
  type        = string
}

variable "key_pair_name" {
  description = "Name to assign to the EC2 key pair in AWS"
  type        = string
  default     = "mmucc-prod-key"
}

variable "public_key_path" {
  description = "Path to your SSH public key file (the .pub file). Terraform uploads this to AWS as the EC2 key pair."
  type        = string
  default     = "~/.ssh/mmucc-prod.pub"
}
