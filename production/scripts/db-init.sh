#!/usr/bin/env bash
# Database schema initialisation script.
# Runs all 31 MySQL DDL + reference-data scripts against the MySQL container.
# Called by the GitHub Actions deploy workflow on first deployment.
# Safe to re-run: scripts use CREATE TABLE IF NOT EXISTS and INSERT IGNORE throughout.
#
# Usage: DB_PASSWORD=xxx DB_NAME=yyy DB_USER=zzz bash db-init.sh <schema-dir>
# Example: bash db-init.sh /tmp/mmucc-schema/mysql

set -euo pipefail

SCHEMA_DIR="${1:?Usage: db-init.sh <path-to-schema-dir>}"
DB_HOST="127.0.0.1"
DB_NAME="${DB_NAME:?DB_NAME must be set}"
DB_USER="${DB_USER:?DB_USER must be set}"
DB_PASSWORD="${DB_PASSWORD:?DB_PASSWORD must be set}"

# ── Wait for MySQL to be ready ────────────────────────────────────────────────
echo "Waiting for MySQL to accept connections..."
for i in $(seq 1 30); do
    if mysqladmin ping -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" --silent 2>/dev/null; then
        echo "MySQL is ready (attempt $i)."
        break
    fi
    if [ "$i" -eq 30 ]; then
        echo "ERROR: MySQL did not become ready after 150 seconds."
        exit 1
    fi
    echo "  Attempt $i/30 — retrying in 5s..."
    sleep 5
done

# ── Session setup ─────────────────────────────────────────────────────────────
echo "Configuring session..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
    -e "SET FOREIGN_KEY_CHECKS=0; \
        SET sql_mode='STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';"

# ── Check if schema already exists ───────────────────────────────────────────
EXISTING=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
    -sN -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$DB_NAME';" 2>/dev/null || echo 0)

if [ "$EXISTING" -ge 31 ]; then
    echo "Schema already initialised ($EXISTING tables found) — skipping script execution."
else
    # ── Run all 31 schema scripts in numbered order ───────────────────────────
    echo "Running schema scripts from $SCHEMA_DIR..."
    SCRIPT_COUNT=0
    for f in $(ls "$SCHEMA_DIR"/*.sql | sort); do
        echo "  $(basename "$f")..."
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$f"
        SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
    done
    echo "Ran $SCRIPT_COUNT script(s)."
fi

# ── Re-enable FK checks ───────────────────────────────────────────────────────
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
    -e "SET FOREIGN_KEY_CHECKS=1;"

# ── Verify table count ────────────────────────────────────────────────────────
echo "Verifying schema..."
TABLE_COUNT=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" \
    -sN -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '$DB_NAME';")
echo "  Tables found: $TABLE_COUNT (expected: 31)"

if [ "$TABLE_COUNT" -lt 31 ]; then
    echo "ERROR: Expected at least 31 tables, found $TABLE_COUNT. Check MySQL logs."
    exit 1
fi

# ── Verify reference data ─────────────────────────────────────────────────────
echo "Verifying reference data..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" -t -e "
SELECT 'REF_CRASH_TYPE_TBL'       AS table_name, COUNT(*) AS row_count FROM REF_CRASH_TYPE_TBL       UNION ALL
SELECT 'REF_HARMFUL_EVENT_TBL',            COUNT(*) FROM REF_HARMFUL_EVENT_TBL     UNION ALL
SELECT 'REF_WEATHER_CONDITION_TBL',        COUNT(*) FROM REF_WEATHER_CONDITION_TBL UNION ALL
SELECT 'REF_SURFACE_CONDITION_TBL',        COUNT(*) FROM REF_SURFACE_CONDITION_TBL UNION ALL
SELECT 'REF_PERSON_TYPE_TBL',             COUNT(*) FROM REF_PERSON_TYPE_TBL       UNION ALL
SELECT 'REF_INJURY_STATUS_TBL',           COUNT(*) FROM REF_INJURY_STATUS_TBL     UNION ALL
SELECT 'REF_BODY_TYPE_TBL',               COUNT(*) FROM REF_BODY_TYPE_TBL;
"

echo "Schema initialisation complete."
