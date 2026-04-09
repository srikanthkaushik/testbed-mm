# MMUCC v5 — AWS Production Deployment Roadmap

**Target:** Single-server AWS deployment behind a DuckDNS domain with HTTPS.
**Stack:** EC2 (Docker Compose) + RDS MySQL + Nginx + Let's Encrypt (DuckDNS DNS-01).

---

## Architecture Overview

```
Internet
   │
   ▼
DuckDNS A record → Elastic IP
   │
   ▼
EC2 t3.medium (Ubuntu 22.04)
   ├── Nginx :443 (SSL termination + reverse proxy + static files)
   │     ├── /            → /var/www/mmucc-app  (Angular SPA)
   │     ├── /auth        → 127.0.0.1:8081      (auth-service)
   │     ├── /admin       → 127.0.0.1:8081      (auth-service admin endpoints)
   │     ├── /crashes     → 127.0.0.1:8082      (crash-service)
   │     ├── /lookups     → 127.0.0.1:8083      (reference-service)
   │     └── /reports     → 127.0.0.1:8084      (report-service)
   │
   ├── Docker Compose (4 Spring Boot services)
   │     ├── auth-service      :8081
   │     ├── crash-service     :8082
   │     ├── reference-service :8083
   │     └── report-service    :8084
   │
   └── Connects to RDS MySQL (private subnet, port 3306)

RDS MySQL 8.0 (db.t3.micro, private subnet, no public access)
```

---

## Phase 1 — AWS Account & Prerequisites

### 1.1 Local Prerequisites
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Docker Desktop installed locally (for building images)
- [ ] Maven 3.9+ and Java 21+ installed locally
- [ ] Node.js 18+ and Angular CLI installed locally
- [ ] Git with access to the repository

### 1.2 DuckDNS Setup
1. Sign in at https://www.duckdns.org
2. Create a subdomain (e.g., `mmucc-app`) — you will get `mmucc-app.duckdns.org`
3. Note your DuckDNS **token** (shown on the dashboard) — needed for SSL cert issuance
4. Leave the IP blank for now; update it in Phase 4 once you have the Elastic IP

### 1.3 Firebase Production Project
1. In the Firebase Console, go to **Project Settings → General**
2. Add `https://mmucc-app.duckdns.org` to **Authorized Domains**
3. Note the production config values (apiKey, authDomain, projectId, etc.)
   — these replace the `PROD_*` placeholders in `environment.prod.ts`
4. Download the **service account JSON** for the production project
   (`Project Settings → Service Accounts → Generate new private key`)
   Store this file securely — it goes to the EC2 instance, not in git.

---

## Phase 2 — AWS Infrastructure

### 2.1 VPC and Networking

Create a VPC with public and private subnets:

| Resource | Value |
|---|---|
| VPC CIDR | `10.0.0.0/16` |
| Public Subnet A | `10.0.1.0/24` (e.g., us-east-1a) |
| Public Subnet B | `10.0.2.0/24` (e.g., us-east-1b) |
| Private Subnet A | `10.0.11.0/24` (e.g., us-east-1a) |
| Private Subnet B | `10.0.12.0/24` (e.g., us-east-1b) |
| Internet Gateway | Attach to VPC |
| Public Route Table | `0.0.0.0/0 → IGW`; associate both public subnets |

> RDS requires subnets in **at least 2 AZs** even for a single-AZ instance — create both private subnets.

### 2.2 Security Groups

**EC2 Security Group (`mmucc-ec2-sg`)**

| Type | Protocol | Port | Source | Purpose |
|---|---|---|---|---|
| Inbound | TCP | 22 | Your IP only | SSH |
| Inbound | TCP | 80 | 0.0.0.0/0 | HTTP (redirect to HTTPS) |
| Inbound | TCP | 443 | 0.0.0.0/0 | HTTPS |
| Outbound | All | All | 0.0.0.0/0 | Outbound traffic |

**RDS Security Group (`mmucc-rds-sg`)**

| Type | Protocol | Port | Source | Purpose |
|---|---|---|---|---|
| Inbound | TCP | 3306 | `mmucc-ec2-sg` | MySQL from EC2 only |
| Outbound | All | All | 0.0.0.0/0 | |

### 2.3 EC2 Instance

| Setting | Value |
|---|---|
| AMI | Ubuntu Server 22.04 LTS (64-bit x86) |
| Instance type | `t3.medium` (2 vCPU, 4 GB RAM) |
| Key pair | Create new key pair → download `.pem` file |
| VPC | The VPC created above |
| Subnet | Public Subnet A |
| Auto-assign public IP | Disable (Elastic IP used instead) |
| Security group | `mmucc-ec2-sg` |
| Storage | 20 GB gp3 EBS |

### 2.4 Elastic IP

1. Allocate a new Elastic IP (EC2 → Elastic IPs → Allocate)
2. Associate it with the EC2 instance
3. **Update the DuckDNS A record** with this Elastic IP

### 2.5 RDS MySQL

| Setting | Value |
|---|---|
| Engine | MySQL 8.0 |
| Template | Free tier / Dev-Test |
| Instance class | `db.t3.micro` |
| Storage | 20 GB gp2, disable autoscaling |
| Multi-AZ | No (single AZ for cost) |
| VPC | The VPC created above |
| Subnet group | Create new DB subnet group using Private Subnet A + B |
| Public access | No |
| Security group | `mmucc-rds-sg` |
| DB name | `mmucc_prod` |
| Master username | `mmucc_admin` |
| Master password | Generate strong password, store in a password manager |
| Parameter group | Default (MySQL 8.0 defaults are fine) |

After creation, note the **RDS endpoint hostname** (e.g., `mmucc-prod.xyz.us-east-1.rds.amazonaws.com`).

### 2.6 S3 Bucket (Backups)

Create a bucket for database backups:
- Bucket name: `mmucc-prod-backups-<account-id>`
- Region: same as EC2
- Block all public access: Yes
- Versioning: Enabled
- Lifecycle rule: expire objects after 30 days

### 2.7 IAM Role for EC2

Create an IAM role (`mmucc-ec2-role`) with these policies:
- `AmazonS3FullAccess` (scoped to the backup bucket) — for DB backup uploads
- `CloudWatchAgentServerPolicy` — for log shipping

Attach the role to the EC2 instance (Actions → Security → Modify IAM role).

---

## Phase 3 — EC2 Server Setup

SSH into the EC2 instance:
```bash
ssh -i /path/to/keypair.pem ubuntu@<ELASTIC_IP>
```

### 3.1 System Packages
```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y nginx certbot python3-certbot-dns-duckdns \
    docker.io docker-compose-v2 awscli mysql-client
sudo systemctl enable nginx docker
sudo usermod -aG docker ubuntu
# Log out and back in for docker group to take effect
```

### 3.2 Directory Structure
```bash
sudo mkdir -p /opt/mmucc/{app,config,logs}
sudo mkdir -p /var/www/mmucc-app
sudo chown -R ubuntu:ubuntu /opt/mmucc
sudo chown -R ubuntu:ubuntu /var/www/mmucc-app
```

### 3.3 SSL Certificate (Let's Encrypt via DuckDNS)

Create the DuckDNS credentials file:
```bash
sudo mkdir -p /etc/letsencrypt/duckdns
echo "dns_duckdns_token=<YOUR_DUCKDNS_TOKEN>" | sudo tee /etc/letsencrypt/duckdns/credentials.ini
sudo chmod 600 /etc/letsencrypt/duckdns/credentials.ini
```

Issue the certificate:
```bash
sudo certbot certonly \
  --dns-duckdns \
  --dns-duckdns-credentials /etc/letsencrypt/duckdns/credentials.ini \
  --dns-duckdns-propagation-seconds 60 \
  -d mmucc-app.duckdns.org \
  --email your@email.com \
  --agree-tos \
  --non-interactive
```

Certificate files will be at:
- `/etc/letsencrypt/live/mmucc-app.duckdns.org/fullchain.pem`
- `/etc/letsencrypt/live/mmucc-app.duckdns.org/privkey.pem`

Set up automatic renewal:
```bash
sudo cp /path/to/production/nginx/certbot-renew.sh /etc/cron.daily/certbot-renew
sudo chmod +x /etc/cron.daily/certbot-renew
```

### 3.4 Nginx Configuration
```bash
sudo cp /path/to/production/nginx/nginx.conf /etc/nginx/sites-available/mmucc
# Replace DOMAIN_PLACEHOLDER with your actual DuckDNS subdomain
sudo sed -i 's/DOMAIN_PLACEHOLDER/mmucc-app.duckdns.org/g' /etc/nginx/sites-available/mmucc
sudo ln -sf /etc/nginx/sites-available/mmucc /etc/nginx/sites-enabled/mmucc
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 3.5 Firebase Service Account
```bash
# Copy the production Firebase service account JSON to the server
scp -i keypair.pem firebase-prod-service-account.json ubuntu@<ELASTIC_IP>:/opt/mmucc/config/
chmod 600 /opt/mmucc/config/firebase-prod-service-account.json
```

### 3.6 Environment File
```bash
cp /path/to/production/docker/.env.example /opt/mmucc/app/.env
# Edit /opt/mmucc/app/.env with real values:
#   - DB_HOST, DB_PASSWORD
#   - JWT_SECRET (generate: openssl rand -base64 64)
#   - FIREBASE_SERVICE_ACCOUNT_PATH
nano /opt/mmucc/app/.env
chmod 600 /opt/mmucc/app/.env
```

---

## Phase 4 — Database Initialisation

### 4.1 Connect to RDS and Create Application User
```bash
mysql -h <RDS_ENDPOINT> -u mmucc_admin -p
```
```sql
CREATE DATABASE IF NOT EXISTS mmucc_prod CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mmucc_app'@'%' IDENTIFIED BY '<STRONG_APP_PASSWORD>';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, DROP
      ON mmucc_prod.* TO 'mmucc_app'@'%';
FLUSH PRIVILEGES;
```

### 4.2 Run Schema Scripts
```bash
# From your local machine (with RDS accessible via EC2 SSH tunnel, or from EC2)
for f in $(ls database/mysql/*.sql | sort); do
    mysql -h <RDS_ENDPOINT> -u mmucc_app -p mmucc_prod < "$f"
done
```

> Flyway migrations (crash-service) will run automatically on first startup and handle their own schema. Run only the non-Flyway DDL files manually (reference tables, etc.) — see `database/mysql/README.md` for the exact list.

---

## Phase 5 — Application Build

Run these steps **locally** before deploying to the server.

### 5.1 Update Angular Production Environment

Edit `frontend/mmucc-app/src/environments/environment.prod.ts` — replace all `PROD_*` placeholders with the real Firebase production config values from Phase 1.3.

### 5.2 Build Angular Frontend
```bash
cd frontend/mmucc-app
npm install
ng build --configuration production
# Output: frontend/mmucc-app/dist/mmucc-app/browser/
```

### 5.3 Build Spring Boot Services
```bash
cd backend
mvn clean package -DskipTests
# JARs produced at:
#   auth-service/target/auth-service-*.jar
#   crash-service/target/crash-service-*.jar
#   reference-service/target/reference-service-*.jar
#   report-service/target/report-service-*.jar
```

### 5.4 Build Docker Images and Push to ECR

Create ECR repositories (one per service):
```bash
aws ecr create-repository --repository-name mmucc/auth-service
aws ecr create-repository --repository-name mmucc/crash-service
aws ecr create-repository --repository-name mmucc/reference-service
aws ecr create-repository --repository-name mmucc/report-service
```

Build and push (run `production/scripts/build-all.sh`):
```bash
# Set your AWS account ID and region
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION=us-east-1

# Log in to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

bash production/scripts/build-all.sh
```

---

## Phase 6 — Deploy to EC2

### 6.1 Copy Docker Compose File
```bash
scp -i keypair.pem production/docker/docker-compose.yml ubuntu@<ELASTIC_IP>:/opt/mmucc/app/
```

Update the image URIs in `docker-compose.yml` on the server (replace `AWS_ACCOUNT_ID` and `AWS_REGION`).

### 6.2 Deploy Angular Static Files
```bash
scp -i keypair.pem -r \
  frontend/mmucc-app/dist/mmucc-app/browser/* \
  ubuntu@<ELASTIC_IP>:/var/www/mmucc-app/
```

### 6.3 Start Services
```bash
# On EC2
cd /opt/mmucc/app

# Authenticate to ECR from EC2
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Pull latest images and start
docker compose pull
docker compose up -d

# Check all 4 containers are running
docker compose ps
```

### 6.4 Reload Nginx
```bash
sudo systemctl reload nginx
```

---

## Phase 7 — Verification

### 7.1 Service Health Checks
```bash
# From EC2 — all should return 200
curl -s -o /dev/null -w "%{http_code}" http://localhost:8081/actuator/health
curl -s -o /dev/null -w "%{http_code}" http://localhost:8082/actuator/health
curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/actuator/health
curl -s -o /dev/null -w "%{http_code}" http://localhost:8084/actuator/health
```

### 7.2 End-to-End via Public URL
- [ ] `https://mmucc-app.duckdns.org` loads the Angular login page
- [ ] HTTP → HTTPS redirect works (`curl -I http://mmucc-app.duckdns.org`)
- [ ] SSL cert is valid — no browser warnings
- [ ] Firebase login completes and JWT is issued
- [ ] Crash list loads data from crash-service
- [ ] Lookup dropdowns populate (reference-service)
- [ ] Create a new crash record (end-to-end write path)
- [ ] Download a crash PDF (report-service)
- [ ] Admin page loads for ADMIN role user

### 7.3 Swagger UI (Sanity Check)
- `https://mmucc-app.duckdns.org/auth/swagger-ui.html`
- `https://mmucc-app.duckdns.org/crashes/swagger-ui.html`
- `https://mmucc-app.duckdns.org/lookups/swagger-ui.html`
- `https://mmucc-app.duckdns.org/reports/swagger-ui.html`

### 7.4 Logs
```bash
# Application logs
docker compose logs -f auth-service
docker compose logs -f crash-service

# Nginx access/error logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## Phase 8 — Operational Setup

### 8.1 Automated Database Backups
```bash
sudo cp production/scripts/db-backup.sh /etc/cron.daily/mmucc-db-backup
sudo chmod +x /etc/cron.daily/mmucc-db-backup
# Edit the script to fill in RDS endpoint, password, and S3 bucket name
```

### 8.2 DuckDNS IP Auto-Update (if Elastic IP ever changes)
```bash
# Cron job to keep DuckDNS record current
echo "*/5 * * * * curl -s 'https://www.duckdns.org/update?domains=mmucc-app&token=<TOKEN>&ip=' > /dev/null" \
  | crontab -
```
> With a fixed Elastic IP this rarely changes, but is a useful safety net.

### 8.3 Docker Compose Auto-Start on Reboot
```bash
# On EC2
sudo crontab -e
# Add:
@reboot cd /opt/mmucc/app && docker compose up -d
```

### 8.4 Log Rotation
Docker log rotation is configured in `docker-compose.yml` (max 50 MB, 5 files per service). Nginx logs rotate automatically via `logrotate`.

---

## Phase 9 — Future Improvements (Post-Launch)

| Item | Notes |
|---|---|
| **HTTPS for Swagger** | Currently accessible — consider blocking `/*/swagger-ui` in Nginx for prod |
| **WAF** | AWS WAF on CloudFront or ALB for rate limiting and bot protection |
| **Secrets Manager** | Replace `.env` file with AWS Secrets Manager; inject via ECS task definition or EC2 parameter store |
| **Multi-AZ RDS** | Enable for high availability (`db.t3.small` minimum for Multi-AZ) |
| **ALB + Auto Scaling** | Move from single EC2 to ALB + ASG if traffic grows |
| **CI/CD Pipeline** | GitHub Actions workflow: test → build → push to ECR → SSH deploy on merge to `main` |
| **Monitoring** | CloudWatch dashboards for CPU/memory; SNS alarm if any service goes unhealthy |
| **RDS backups** | Enable automated RDS snapshots (7-day retention) in addition to the cron mysqldump |
