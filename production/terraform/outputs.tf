output "elastic_ip" {
  description = "Elastic IP address — set your DuckDNS A record to this value, then add it as EC2_HOST in GitHub Secrets"
  value       = aws_eip.app.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "s3_backup_bucket" {
  description = "S3 bucket name for daily database backups"
  value       = aws_s3_bucket.backups.bucket
}

output "ecr_registry" {
  description = "ECR registry base URL (use as AWS_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com)"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "ecr_repositories" {
  description = "ECR repository URIs for all 4 services"
  value       = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ~/.ssh/mmucc-prod ubuntu@${aws_eip.app.public_ip}"
}
