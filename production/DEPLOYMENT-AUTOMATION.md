# MMUCC v5 — Deployment Automation Guide

This document covers the automated deployment pipeline for MMUCC v5. It complements
`DEPLOYMENT.md` (the manual step-by-step reference) and should be followed instead of
the manual guide for new deployments.

---

## What Is Automated

| Component | Tool | What it does |
|---|---|---|
| AWS infrastructure | **Terraform** | Creates VPC, subnet, security group, EC2 (t3.micro), EIP, S3 bucket, IAM role, ECR repositories — in a single command |
| EC2 server bootstrap | **User Data script** | Runs on first boot: installs packages, creates swap, sets up directories and cron jobs |
| Build + image push | **GitHub Actions** | On every push to `master`: builds JARs, builds Angular, pushes 4 Docker images to ECR |
| Deploy | **GitHub Actions** | SSHes into EC2, pulls new images, restarts containers |
| DB schema init | **db-init.sh** | Runs all 31 schema scripts on first deploy only; verified idempotent |
| SSL certificate | **GitHub Actions** | Issues Let's Encrypt cert via DuckDNS DNS-01 on first deploy only |
| Nginx config | **GitHub Actions** | Applies `nginx.conf` and reloads on first deploy only |
| DB backup cron | **GitHub Actions** | Installs db-backup.sh to `/etc/cron.daily` on first deploy only |

## What Remains Manual (unavoidable)

| Step | Why |
|---|---|
| Create AWS account | No automation possible |
| Create IAM user for CI/CD | One-time console action |
| Register DuckDNS subdomain | Requires browser login at duckdns.org |
| Set up Firebase project + download service account JSON | Requires Firebase Console |
| Generate SSH key pair | Local command — private key must never leave your machine |
| Add GitHub Secrets | One-time console action |
| Promote first admin user | Requires a first Firebase login to exist in the DB |

---

## File Structure

```
production/
├── terraform/
│   ├── main.tf                    AWS resources (VPC, EC2, EIP, S3, ECR, IAM)
│   ├── variables.tf               Input variable definitions
│   ├── outputs.tf                 Outputs: Elastic IP, ECR URIs, SSH command
│   ├── terraform.tfvars.example   Copy → terraform.tfvars and fill in
│   └── .gitignore                 Excludes *.tfstate, .terraform/, terraform.tfvars
│
├── scripts/
│   ├── user-data.sh               EC2 first-boot bootstrap (run by Terraform via user_data)
│   ├── db-init.sh                 Schema initialisation (run by GitHub Actions on first deploy)
│   ├── db-backup.sh               Daily mysqldump to S3 (installed to /etc/cron.daily)
│   └── build-all.sh               Local Docker build + ECR push (used by GitHub Actions)
│
├── docker/
│   ├── docker-compose.yml         5-container stack: MySQL + 4 Spring Boot services
│   └── .env.example               Template for /opt/mmucc/app/.env on EC2
│
├── nginx/
│   └── nginx.conf                 Nginx reverse proxy + SSL config (DOMAIN_PLACEHOLDER replaced at deploy)
│
├── aws/
│   └── resources.md               Fill in actual resource IDs after terraform apply
│
├── DEPLOYMENT.md                  Manual deployment reference (superseded by this guide for new deploys)
└── DEPLOYMENT-AUTOMATION.md       This file

.github/
└── workflows/
    └── deploy.yml                 GitHub Actions CI/CD pipeline
```

---

## Prerequisites

Before running anything, complete these one-time steps:

### Step 1 — Generate an SSH key pair

```bash
ssh-keygen -t ed25519 -f ~/.ssh/mmucc-prod -C "mmucc-prod"
# Creates:  ~/.ssh/mmucc-prod      (private key — never share or commit)
#           ~/.ssh/mmucc-prod.pub  (public key — given to Terraform)
```

### Step 2 — Create an IAM user for GitHub Actions (CI/CD only)

In the AWS Console → IAM → Users → Create user (`mmucc-cicd`).

Attach this inline policy (ECR push permissions only — principle of least privilege):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:*:*:repository/mmucc/*"
    }
  ]
}
```

Generate an **Access Key** (type: CLI) and note the `Access Key ID` and `Secret Access Key`.

### Step 3 — Register a DuckDNS subdomain

1. Sign in at https://www.duckdns.org
2. Create a subdomain (e.g. `mmucc-app`) → you get `mmucc-app.duckdns.org`
3. Note your **DuckDNS token** (shown on the dashboard)
4. Leave the IP blank for now — it is set automatically by the EC2 cron job after first deploy

### Step 4 — Set up Firebase

1. In Firebase Console → Project Settings → General → Add `https://mmucc-app.duckdns.org` to **Authorized Domains**
2. Go to **Service Accounts → Generate new private key** → download the JSON file
3. Base64-encode it for storage as a GitHub Secret:
   ```bash
   base64 -w 0 firebase-service-account.json
   # Copy the output — this is FIREBASE_SERVICE_ACCOUNT_B64
   ```

### Step 5 — Install Terraform locally

```bash
# macOS
brew install terraform

# Linux
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip && sudo mv terraform /usr/local/bin/

# Windows (Chocolatey)
choco install terraform

terraform version   # should print >= 1.6
```

### Step 6 — Configure AWS CLI

```bash
aws configure
# AWS Access Key ID:     (your personal/admin key — NOT the mmucc-cicd key)
# AWS Secret Access Key: ...
# Default region:        us-east-1
# Default output format: json
```

---

## Deployment Steps

### Phase A — Terraform: provision AWS infrastructure

```bash
cd production/terraform

# 1. Copy and fill in your variables
cp terraform.tfvars.example terraform.tfvars
#    Edit terraform.tfvars:
#      ssh_allowed_cidr = "YOUR_IP/32"   (get it from https://checkip.amazonaws.com)
#      public_key_path  = "~/.ssh/mmucc-prod.pub"

# 2. Initialise Terraform
terraform init

# 3. Preview what will be created
terraform plan

# 4. Create all AWS resources (~2 minutes)
terraform apply
```

**Note the outputs** — you need these values for the next steps:

```
elastic_ip       = "1.2.3.4"
ecr_repositories = { auth-service = "...", crash-service = "...", ... }
s3_backup_bucket = "mmucc-prod-backups-123456789012"
ssh_command      = "ssh -i ~/.ssh/mmucc-prod ubuntu@1.2.3.4"
```

Record actual values in `production/aws/resources.md`.

### Phase B — Update DuckDNS A record

Go to https://www.duckdns.org and set your subdomain's IP to the `elastic_ip` from Terraform output.

> The EC2 boot takes ~3–5 minutes. Verify the server is up before proceeding:
> ```bash
> ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> "cat /var/log/mmucc-bootstrap.log | tail -5"
> # Should end with: "=== MMUCC bootstrap complete at ..."
> ```

### Phase C — Add GitHub Secrets

In your GitHub repository → **Settings → Secrets and variables → Actions → New repository secret**, add all of the following:

| Secret name | Value | Source |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | mmucc-cicd IAM access key ID | Step 2 above |
| `AWS_SECRET_ACCESS_KEY` | mmucc-cicd IAM secret key | Step 2 above |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID | AWS Console → top-right dropdown |
| `AWS_REGION` | `us-east-1` (or your region) | Terraform tfvars |
| `EC2_HOST` | Elastic IP address | Terraform output |
| `EC2_SSH_KEY` | Contents of `~/.ssh/mmucc-prod` (private key) | Step 1 above |
| `DB_NAME` | `mmucc_prod` | Your choice |
| `DB_USER` | `mmucc_app` | Your choice |
| `DB_PASSWORD` | Strong password | Generate: `openssl rand -base64 24` |
| `DB_ROOT_PASSWORD` | Strong password | Generate: `openssl rand -base64 24` |
| `JWT_SECRET` | Base64 secret (min 512 bits) | Generate: `openssl rand -base64 64` |
| `DUCKDNS_DOMAIN` | Your subdomain only, e.g. `mmucc-app` | Step 3 above |
| `DUCKDNS_TOKEN` | DuckDNS token | Step 3 above |
| `CERTBOT_EMAIL` | Your email address | For Let's Encrypt expiry notices |
| `FIREBASE_SERVICE_ACCOUNT_B64` | Base64-encoded service account JSON | Step 4 above |
| `S3_BACKUP_BUCKET` | `mmucc-prod-backups-<account-id>` | Terraform output |

### Phase D — Trigger the first deployment

Push any commit to `master` (or trigger manually via GitHub Actions → `workflow_dispatch`):

```bash
git commit --allow-empty -m "chore: trigger initial production deployment"
git push origin master
```

Watch the workflow run at: `https://github.com/<owner>/<repo>/actions`

**First-deploy runtime: ~10–15 minutes.** Subsequent deploys: ~5–7 minutes.

#### What happens on first deploy:

1. Maven builds 4 Spring Boot JARs
2. Angular builds the frontend (`dist/`)
3. 4 Docker images are built and pushed to ECR
4. Files are SCP'd to EC2: `.env`, `docker-compose.yml`, Angular dist, Firebase SA, schema scripts
5. `docker compose pull && docker compose up -d` starts MySQL + 4 Spring Boot services
6. **First-deploy block** (detected via `/opt/mmucc/.initialized` flag):
   - `db-init.sh` runs all 31 schema scripts and verifies 31 tables
   - DuckDNS cron is configured with your token
   - Let's Encrypt SSL cert is issued via DuckDNS DNS-01 challenge
   - `nginx.conf` is applied and Nginx reloads
   - `db-backup.sh` is installed to `/etc/cron.daily`
   - `/opt/mmucc/.initialized` is created (prevents re-running)
7. Health checks verify all 4 Spring Boot services return HTTP 200

#### What happens on subsequent deploys:

Steps 1–5 run again. Step 6 is skipped (`.initialized` exists). Step 7 runs again.

### Phase E — Promote the first admin user

After the first successful deployment:

1. Navigate to `https://mmucc-app.duckdns.org` and sign in with Firebase
2. SSH into EC2 and promote your account:

```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP>
mysql -h 127.0.0.1 -u mmucc_app -p mmucc_prod
```
```sql
UPDATE APP_USER_TBL
SET    AUS_ROLE = 'ADMIN',
       AUS_IS_ACTIVE = 1,
       AUS_MODIFIED_BY = 'bootstrap',
       AUS_MODIFIED_DT = NOW()
WHERE  AUS_EMAIL = 'your@email.com';
```

---

## How the Pipeline Works

```
git push master
      │
      ▼
GitHub Actions runner (ubuntu-latest)
  │
  ├── mvn clean package -DskipTests
  ├── ng build --configuration production
  ├── docker build + push × 4  ──────────────────► ECR (4 repos)
  │
  └── SSH into EC2 (Elastic IP)
        ├── Copy: .env, docker-compose.yml, Angular dist,
        │         Firebase SA, schema scripts
        ├── docker compose pull && docker compose up -d
        │
        └── (first deploy only)
              ├── db-init.sh  ──► MySQL container (31 schema scripts)
              ├── certbot      ──► Let's Encrypt (DuckDNS DNS-01)
              ├── nginx.conf   ──► /etc/nginx/sites-enabled/mmucc
              └── db-backup.sh ──► /etc/cron.daily/mmucc-db-backup
```

---

## Useful Commands

### Check bootstrap log (after terraform apply)
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> "sudo cat /var/log/mmucc-bootstrap.log"
```

### View running containers
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> "cd /opt/mmucc/app && docker compose ps"
```

### Tail service logs
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> \
  "cd /opt/mmucc/app && docker compose logs -f crash-service"
```

### Manual health check
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> << 'EOF'
  for PORT in 8081 8082 8083 8084; do
    echo -n "Port $PORT: "
    curl -s -o /dev/null -w "%{http_code}\n" http://localhost:$PORT/actuator/health
  done
EOF
```

### Check memory usage
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP> "free -h && docker stats --no-stream"
```

### Re-run schema init manually (if needed)
```bash
ssh -i ~/.ssh/mmucc-prod ubuntu@<ELASTIC_IP>
# Then on EC2:
source /opt/mmucc/app/.env
DB_PASSWORD="$DB_PASSWORD" DB_NAME="$DB_NAME" DB_USER="$DB_USER" \
  bash /tmp/db-init.sh /tmp/mmucc-schema/mysql
```

### Tear down all AWS resources
```bash
cd production/terraform
terraform destroy
# ⚠️ This permanently deletes EC2, EIP, S3, ECR repos, and all data.
# MySQL data on EBS is deleted when EC2 is terminated.
```

---

## Troubleshooting

| Symptom | Check |
|---|---|
| Terraform apply fails | `aws sts get-caller-identity` — confirms credentials are set |
| Bootstrap didn't run | `ssh ... "sudo cat /var/log/mmucc-bootstrap.log"` |
| GitHub Actions SSH fails | Verify `EC2_SSH_KEY` secret contains the full private key including headers |
| Docker compose pull fails | EC2 IAM role may not have ECR pull permission — check `terraform apply` completed |
| `db-init.sh` fails | MySQL container may not be healthy yet — check `docker compose ps mysql` |
| SSL cert fails | DuckDNS A record must point to the Elastic IP before certbot runs |
| Services return 503 | Nginx config applied before Spring Boot started — wait ~60s and retry |
| OOM / containers restarting | Run `free -h` — if swap is being used heavily, upgrade to t3.small |

---

## Next Steps

- [ ] **Complete Phase A:** Run `terraform apply` from `production/terraform/`
- [ ] **Complete Phase B:** Point DuckDNS A record to the Elastic IP from Terraform output
- [ ] **Complete Phase C:** Add all 16 GitHub Secrets listed above
- [ ] **Complete Phase D:** Push to `master` to trigger first deployment; watch the Actions run
- [ ] **Complete Phase E:** Sign in, then promote your account to ADMIN via SQL
- [ ] **Verify:** Open `https://mmucc-app.duckdns.org` — login, create a crash, download a PDF
- [ ] **Record resource IDs** in `production/aws/resources.md`
- [ ] **Monitor memory** for the first 24 hours (`free -h`, `docker stats`) — upgrade to t3.small if swap usage is consistently high
