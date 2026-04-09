#!/usr/bin/env bash
# Renew Let's Encrypt certificate via DuckDNS DNS-01 challenge.
# Place in /etc/cron.daily/certbot-renew and chmod +x.

set -euo pipefail

DOMAIN="mmucc-app.duckdns.org"
CREDENTIALS="/etc/letsencrypt/duckdns/credentials.ini"
LOG="/var/log/letsencrypt/renew.log"

certbot renew \
  --dns-duckdns \
  --dns-duckdns-credentials "$CREDENTIALS" \
  --dns-duckdns-propagation-seconds 60 \
  --quiet \
  >> "$LOG" 2>&1

# Reload Nginx if the cert was renewed
if certbot certificates -d "$DOMAIN" 2>&1 | grep -q "VALID"; then
    systemctl reload nginx >> "$LOG" 2>&1
fi
