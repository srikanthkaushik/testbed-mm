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

Create a minimal VPC with a single public subnet. No private subnets are needed — MySQL runs on the EC2 instance, not on a separate managed service.

| Resource | Value |
|---|---|
| VPC CIDR | `10.0.0.0/16` |
| Public Subnet | `10.0.1.0/24` (e.g., us-east-1a) |
| Internet Gateway | Attach to VPC |
| Public Route Table | `0.0.0.0/0 → IGW`; associate the public subnet |

### 2.2 Security Groups

**EC2 Security Group (`mmucc-ec2-sg`)**

| Type | Protocol | Port | Source | Purpose |
|---|---|---|---|---|
| Inbound | TCP | 22 | Your IP only | SSH |
| Inbound | TCP | 80 | 0.0.0.0/0 | HTTP (redirect to HTTPS) |
| Inbound | TCP | 443 | 0.0.0.0/0 | HTTPS |
| Outbound | All | All | 0.0.0.0/0 | Outbound traffic |

> Port 3306 (MySQL) is **not** open inbound — the database is accessible only on the loopback interface (`127.0.0.1`) within the EC2 instance itself.

### 2.3 EC2 Instance

| Setting | Value |
|---|---|
| AMI | Ubuntu Server 22.04 LTS (64-bit x86) |
| Instance type | `t3.micro` (2 vCPU, 1 GB RAM) — free tier eligible |
| Key pair | Create new key pair → download `.pem` file |
| VPC | The VPC created above |
| Subnet | Public Subnet |
| Auto-assign public IP | Disable (Elastic IP used instead) |
| Security group | `mmucc-ec2-sg` |
| Storage | 30 GB **gp2** EBS (OS + MySQL data volume) — free tier eligible |

### 2.4 Elastic IP

1. Allocate a new Elastic IP (EC2 → Elastic IPs → Allocate)
2. Associate it with the EC2 instance
3. **Update the DuckDNS A record** with this Elastic IP

### 2.5 S3 Bucket (Backups)

Create a bucket for database backups:
- Bucket name: `mmucc-prod-backups-<account-id>`
- Region: same as EC2
- Block all public access: Yes
- Versioning: Enabled
- Lifecycle rule: expire objects after 30 days

### 2.6 IAM Role for EC2

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

### 3.2 Swap File

t3.micro has 1 GB RAM. Five containers (4 JVMs + MySQL) will use up to ~1.2 GB at peak. A 1 GB swap file provides headroom for load spikes without OOM-killing containers.

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent across reboots
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Reduce swap aggressiveness (only swap when RAM is nearly full)
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Verify
free -h   # should show 1 GB swap
```

### 3.3 Directory Structure
```bash
sudo mkdir -p /opt/mmucc/{app,config,logs,mysql-data}
sudo mkdir -p /var/www/mmucc-app
sudo chown -R ubuntu:ubuntu /opt/mmucc
sudo chown -R ubuntu:ubuntu /var/www/mmucc-app
```

### 3.4 SSL Certificate (Let's Encrypt via DuckDNS)

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

### 3.5 Nginx Configuration
```bash
sudo cp /path/to/production/nginx/nginx.conf /etc/nginx/sites-available/mmucc
# Replace DOMAIN_PLACEHOLDER with your actual DuckDNS subdomain
sudo sed -i 's/DOMAIN_PLACEHOLDER/mmucc-app.duckdns.org/g' /etc/nginx/sites-available/mmucc
sudo ln -sf /etc/nginx/sites-available/mmucc /etc/nginx/sites-enabled/mmucc
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 3.6 Firebase Service Account
```bash
# Copy the production Firebase service account JSON to the server
scp -i keypair.pem firebase-prod-service-account.json ubuntu@<ELASTIC_IP>:/opt/mmucc/config/
chmod 600 /opt/mmucc/config/firebase-prod-service-account.json
```

### 3.7 Environment File
```bash
cp /path/to/production/docker/.env.example /opt/mmucc/app/.env
# Edit /opt/mmucc/app/.env with real values:
#   - DB_PASSWORD, DB_ROOT_PASSWORD
#   - JWT_SECRET (generate: openssl rand -base64 64)
nano /opt/mmucc/app/.env
chmod 600 /opt/mmucc/app/.env
```

---

## Phase 4 — Database Initialisation

MySQL runs as a Docker container on the EC2 instance. The database and application user are created automatically by the container on first start using the credentials in `.env`.

### 4.1 Start the MySQL Container

```bash
cd /opt/mmucc/app
docker compose up -d mysql

# Wait for the container to pass its health check (up to ~60 seconds)
docker compose ps mysql   # STATUS should show "(healthy)"
```

On first start, Docker initialises `/opt/mmucc/mysql-data` with a fresh MySQL data directory and creates:
- Database `mmucc_prod` (from `DB_NAME`)
- User `mmucc_app` with full privileges on `mmucc_prod` (from `DB_USER` / `DB_PASSWORD`)

### 4.2 Copy Schema Scripts to EC2

The `database/mysql/` directory contains 31 numbered SQL files (DDL + reference data INSERTs). Copy them from your local machine:

```bash
scp -i keypair.pem -r database/mysql ubuntu@<ELASTIC_IP>:/tmp/mmucc-schema/
```

### 4.3 Run All Schema Scripts in Order

SSH into EC2, then run all 31 scripts in numbered order:

```bash
ssh -i keypair.pem ubuntu@<ELASTIC_IP>

# Set session variables before running scripts
mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod \
  -e "SET FOREIGN_KEY_CHECKS=0; SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';"

# Run all scripts in order
cd /tmp/mmucc-schema/mysql
for f in $(ls *.sql | sort); do
    echo "Running $f..."
    mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod < "$f"
done

# Re-enable FK checks
mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod \
  -e "SET FOREIGN_KEY_CHECKS=1;"
```

**What these scripts create:**
- Scripts 01–07: 7 reference tables (`REF_*`) pre-loaded with all MMUCC coded values
- Scripts 08–29: All 22 MMUCC data tables (`CRASH_TBL`, `VEHICLE_TBL`, `PERSON_TBL`, and all child tables)
- Script 30: `APP_USER_TBL` (application users)
- Script 31: `CRASH_AUDIT_LOG_TBL` (before/after JSON audit log)

> **Flyway note:** crash-service runs Flyway migrations automatically on first startup. V1 uses `CREATE TABLE IF NOT EXISTS` (no-op since tables already exist). V3–V7 apply `ALTER TABLE` patches to align column types (INT UNSIGNED → BIGINT) and fix data types — these run against the tables created above. This is the intended workflow; do not skip the manual scripts.

### 4.4 Verify Schema

```bash
mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod
```
```sql
-- Should return 31 tables
SELECT COUNT(*) AS table_count
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'mmucc_prod';

-- Verify reference data was loaded (expected: 7, 51, 12, 9, 10, 5, 29)
SELECT 'REF_CRASH_TYPE_TBL'       AS tbl, COUNT(*) AS rows FROM REF_CRASH_TYPE_TBL       UNION ALL
SELECT 'REF_HARMFUL_EVENT_TBL',          COUNT(*)          FROM REF_HARMFUL_EVENT_TBL     UNION ALL
SELECT 'REF_WEATHER_CONDITION_TBL',      COUNT(*)          FROM REF_WEATHER_CONDITION_TBL UNION ALL
SELECT 'REF_SURFACE_CONDITION_TBL',      COUNT(*)          FROM REF_SURFACE_CONDITION_TBL UNION ALL
SELECT 'REF_PERSON_TYPE_TBL',           COUNT(*)           FROM REF_PERSON_TYPE_TBL       UNION ALL
SELECT 'REF_INJURY_STATUS_TBL',         COUNT(*)           FROM REF_INJURY_STATUS_TBL     UNION ALL
SELECT 'REF_BODY_TYPE_TBL',             COUNT(*)           FROM REF_BODY_TYPE_TBL;

EXIT;
```

### 4.5 Create the First Admin User

After the services are running (Phase 6), the first user who logs in via Firebase is auto-provisioned as `VIEWER`. Promote them to `ADMIN` directly in the database:

```bash
mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod
```
```sql
-- Run after Phase 6 (first login must occur first)
UPDATE APP_USER_TBL
SET    AUS_ROLE = 'ADMIN',
       AUS_IS_ACTIVE = 1,
       AUS_MODIFIED_BY = 'db-admin',
       AUS_MODIFIED_DT = NOW()
WHERE  AUS_EMAIL = '<YOUR_ADMIN_EMAIL>';
```

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

# Authenticate to ECR (needed for the 4 Spring Boot images; MySQL pulls from Docker Hub)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com

# Pull all images (mysql:8.0 from Docker Hub + 4 Spring Boot images from ECR)
docker compose pull

# Start — MySQL comes up first; Spring Boot services wait for its health check
docker compose up -d

# Check all 5 containers are running
docker compose ps
```

> The `depends_on: condition: service_healthy` in `docker-compose.yml` ensures the Spring Boot services only start after MySQL passes its `mysqladmin ping` health check. On first boot this takes 20–60 seconds.

### 6.4 Reload Nginx
```bash
sudo systemctl reload nginx
```

---

## Phase 7 — Verification

### 7.1 Service Health Checks
```bash
# Verify MySQL container is healthy
docker compose ps mysql

# Verify all 4 Spring Boot services return 200
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
# Edit the script to fill in DB_PASSWORD and S3_BUCKET name
# DB_HOST is already set to 127.0.0.1 (MySQL container on same host)
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
Docker log rotation is configured in `docker-compose.yml` (max 50 MB, 5 files per container, covering mysql + all 4 services). Nginx logs rotate automatically via `logrotate`.

---

## Estimated Monthly AWS Cost

> **Assumptions:** us-east-1 region, on-demand pricing, Linux, MySQL runs as a Docker container on the same EC2 instance (no RDS), low traffic (< 5 GB data transfer out/month). Prices reflect AWS published rates as of early 2025. Actual charges will vary.

### Months 1–12 (AWS Free Tier)

| AWS Service | Configuration | Free allowance | $/month |
|---|---|---|---|
| **EC2** | t3.micro — 1 GB RAM, free-tier eligible | 750 hrs/month | $0.00 |
| **EBS** | 30 GB gp2 | 30 GB/month | $0.00 |
| **Public IPv4** | Elastic IP (associated with running instance) | 750 hrs/month | $0.00 |
| **S3** | Daily DB backups < 100 MB/month | 5 GB + 20K GET + 2K PUT | $0.00 |
| **ECR** | ~1 GB (4 Spring Boot images) | 500 MB/month free | ~$0.05 |
| **Data Transfer Out** | Low traffic | 100 GB/month free | $0.00 |
| **VPC / IGW** | No per-resource charge | — | $0.00 |
| **DuckDNS / Let's Encrypt / Firebase Auth** | — | Free | $0.00 |
| | | **Total (months 1–12)** | **~$0.05/month** |

### Month 13+ (After Free Tier Expires)

| AWS Service | Configuration | Unit price | $/month |
|---|---|---|---|
| **EC2** | t3.micro | $0.0104/hr | $7.59 |
| **EBS** | 30 GB gp2 | $0.10/GB | $3.00 |
| **Elastic IP** | 1 public IPv4 | $0.005/hr | $3.65 |
| **ECR** | ~1 GB images | $0.10/GB | $0.10 |
| **S3 + transfer + free services** | — | — | ~$0.00 |
| | | **Total (month 13+)** | **~$14/month** |

---

### Running 5 Containers on 1 GB RAM (t3.micro)

t3.micro has 1 GB RAM. With JVM heap tuning and a 1 GB swap file (configured in Phase 3.2), all five containers fit comfortably at idle and handle load spikes via swap.

| Process | Idle RSS (tuned) | Peak RSS |
|---|---|---|
| auth-service (JVM) | ~110 MB | ~200 MB |
| crash-service (JVM) | ~120 MB | ~230 MB |
| reference-service (JVM) | ~90 MB | ~160 MB |
| report-service (JVM) | ~110 MB | ~200 MB |
| MySQL 8.0 (64 MB buffer pool) | ~100 MB | ~128 MB |
| Nginx + OS + Docker | ~200 MB | ~250 MB |
| **Total** | **~730 MB** | **~1,168 MB** |

At idle the instance stays within 1 GB. During load spikes (e.g. PDF generation) it draws on swap briefly. The `JAVA_OPTS` set in `docker-compose.yml` and MySQL flags enforce these limits.

If the instance hits swap consistently (check with `free -h` and `vmstat 1`), upgrade to t3.small (2 GB, ~$15/month after free tier) — no other changes required.

---

### Trade-offs vs. RDS

| | MySQL on EC2 (this setup) | RDS db.t3.micro |
|---|---|---|
| Monthly cost | included in EC2 | +$14.71/month |
| Managed patching | Manual | Automatic |
| Point-in-time recovery | No (cron mysqldump to S3 only) | Yes (up to 35 days) |
| Automated snapshots | No | Yes |
| Failover | No | No (Single-AZ) |
| Disk failure risk | Shared EBS with OS | Separate managed storage |

The S3 backup cron (`production/scripts/db-backup.sh`) mitigates the loss of managed backups — ensure it is running and verify restores periodically.

---

## Phase 9 — Future Improvements (Post-Launch)

| Item | Notes |
|---|---|
| **HTTPS for Swagger** | Currently accessible — consider blocking `/*/swagger-ui` in Nginx for prod |
| **WAF** | AWS WAF on CloudFront or ALB for rate limiting and bot protection |
| **Secrets Manager** | Replace `.env` file with AWS Secrets Manager; inject via EC2 Parameter Store |
| **Migrate to RDS** | Move MySQL off EC2 to RDS db.t3.micro (~+$15/month) for managed patching, automated snapshots, and point-in-time recovery |
| **ALB + Auto Scaling** | Move from single EC2 to ALB + ASG if traffic grows |
| **CI/CD Pipeline** | GitHub Actions workflow: test → build → push to ECR → SSH deploy on merge to `main` |
| **Monitoring** | CloudWatch dashboards for CPU/memory; SNS alarm if any service goes unhealthy |
| **EBS Snapshots** | Schedule automated EBS snapshots via AWS Data Lifecycle Manager to protect MySQL data on disk |
