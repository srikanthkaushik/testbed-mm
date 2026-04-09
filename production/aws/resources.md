# AWS Resource Inventory

Record actual values here after creation. Do not commit secrets.

## VPC

| Resource | Name | Value |
|---|---|---|
| VPC | mmucc-prod-vpc | |
| Public Subnet A | mmucc-public-1a | |
| Public Subnet B | mmucc-public-1b | |
| Private Subnet A | mmucc-private-1a | |
| Private Subnet B | mmucc-private-1b | |
| Internet Gateway | mmucc-igw | |

## EC2

| Resource | Value |
|---|---|
| Instance ID | |
| Instance type | t3.medium |
| AMI | Ubuntu 22.04 LTS |
| Elastic IP | |
| Key pair name | |
| Security group | mmucc-ec2-sg |
| IAM role | mmucc-ec2-role |

## RDS

| Resource | Value |
|---|---|
| DB identifier | mmucc-prod |
| Endpoint | |
| Engine | MySQL 8.0 |
| Instance class | db.t3.micro |
| Database name | mmucc_prod |
| Security group | mmucc-rds-sg |

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
