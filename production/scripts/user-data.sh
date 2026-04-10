#!/usr/bin/env bash
# EC2 User Data — MMUCC v5 production server bootstrap.
# Runs automatically as root on first boot via Terraform user_data.
# Sets up: system packages, swap file, directories, Docker, Nginx, cron jobs.
# Does NOT start the application — that is handled by the GitHub Actions deploy workflow.

set -euo pipefail
exec > /var/log/mmucc-bootstrap.log 2>&1

echo "=== MMUCC bootstrap starting at $(date) ==="

# ── System packages ───────────────────────────────────────────────────────────
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y \
    nginx \
    certbot \
    python3-certbot-dns-duckdns \
    docker.io \
    docker-compose-v2 \
    awscli \
    mysql-client \
    curl \
    jq \
    unzip

systemctl enable nginx docker
systemctl start docker

# Allow the ubuntu user to run Docker without sudo
usermod -aG docker ubuntu

# ── Swap file (1 GB) ──────────────────────────────────────────────────────────
# Required for t3.micro (1 GB RAM) running 4 JVMs + MySQL container.
if [ ! -f /swapfile ]; then
    echo "Creating 1 GB swap file..."
    fallocate -l 1G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    # Only swap under memory pressure — avoids unnecessary disk I/O
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p
fi

# ── Directory structure ───────────────────────────────────────────────────────
mkdir -p /opt/mmucc/{app,config,logs,mysql-data}
mkdir -p /opt/mmucc/logs/{auth,crash,reference,report}
mkdir -p /var/www/mmucc-app
chown -R ubuntu:ubuntu /opt/mmucc
chown -R ubuntu:ubuntu /var/www/mmucc-app

# ── Docker auto-start on reboot ───────────────────────────────────────────────
# Starts all containers (mysql + 4 Spring Boot services) after any EC2 reboot.
cat > /etc/cron.d/mmucc-autostart << 'EOF'
@reboot ubuntu sleep 30 && cd /opt/mmucc/app && docker compose up -d >> /var/log/mmucc-autostart.log 2>&1
EOF
chmod 644 /etc/cron.d/mmucc-autostart

# ── DB backup cron (placeholder — configured by deploy workflow on first deploy)
# The GitHub Actions first-deploy step writes the real values.
cat > /etc/cron.daily/mmucc-db-backup << 'EOF'
#!/usr/bin/env bash
# Populated by GitHub Actions first-deploy step.
# Run manually to verify: bash /etc/cron.daily/mmucc-db-backup
EOF
chmod +x /etc/cron.daily/mmucc-db-backup

echo "=== MMUCC bootstrap complete at $(date) ==="
