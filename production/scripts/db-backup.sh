#!/usr/bin/env bash
# Daily database backup to S3.
# MySQL runs as a Docker container on the same EC2 instance.
# Place in /etc/cron.daily/mmucc-db-backup and chmod +x.
# Fill in DB_PASSWORD and S3_BUCKET before deploying.

set -euo pipefail

DB_HOST="127.0.0.1"
DB_NAME="mmucc_prod"
DB_USER="mmucc_app"
DB_PASSWORD="CHANGE_ME"
S3_BUCKET="mmucc-prod-backups-123456789012"
BACKUP_DIR="/tmp/mmucc-backups"
DATE=$(date +%Y-%m-%d-%H%M)
FILENAME="mmucc-prod-${DATE}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "[$DATE] Starting backup..."
mysqldump \
  -h "$DB_HOST" \
  -u "$DB_USER" \
  -p"$DB_PASSWORD" \
  --single-transaction \
  --routines \
  --triggers \
  "$DB_NAME" | gzip > "$BACKUP_DIR/$FILENAME"

echo "Uploading to s3://$S3_BUCKET/backups/$FILENAME"
aws s3 cp "$BACKUP_DIR/$FILENAME" "s3://$S3_BUCKET/backups/$FILENAME"

rm -f "$BACKUP_DIR/$FILENAME"
echo "Backup complete: $FILENAME"
