# AWS Resource Inventory

Record actual values here after creation. Do not commit secrets.

## VPC

| Resource | Name | Value |
|---|---|---|
| VPC | mmucc-prod-vpc | |
| Public Subnet | mmucc-public-1a | |
| Internet Gateway | mmucc-igw | |

## EC2

| Resource | Value |
|---|---|
| Instance ID | |
| Instance type | t3.small |
| AMI | Ubuntu 22.04 LTS |
| Elastic IP | |
| Key pair name | |
| Security group | mmucc-ec2-sg |
| IAM role | mmucc-ec2-role |
| Storage | 30 GB gp3 EBS (OS + MySQL data) |

## ECR Repositories

| Repository | URI |
|---|---|
| mmucc/auth-service | |
| mmucc/crash-service | |
| mmucc/reference-service | |
| mmucc/report-service | |

## S3

| Bucket | Purpose |
|---|---|
| mmucc-prod-backups-\<account-id\> | Daily mysqldump backups |

## DuckDNS

| Setting | Value |
|---|---|
| Subdomain | mmucc-app.duckdns.org |
| A record → | (Elastic IP above) |
