# MMUCC v5 Database Setup Guide

## Prerequisites

- MySQL 8.0 or later
- A database has already been created and credentials are available
- MySQL client (`mysql`) available in the PATH

---

## Naming Conventions

| Convention | Rule |
|---|---|
| Table names | UPPERCASE with `_TBL` suffix (e.g., `CRASH_TBL`) |
| Column names | UPPERCASE with 3-letter table acronym prefix and underscore (e.g., `CRS_CRASH_DATE`) |
| Coded values | Stored as `TINYINT`/`SMALLINT`; valid values documented in column `COMMENT` |
| Audit columns | Every table has `CREATED_BY`, `CREATED_DT`, `MODIFIED_BY`, `MODIFIED_DT`, `LAST_UPDATED_ACTIVITY_CODE` — all prefixed with the table acronym |
| No ENUM types | All coded/status columns use `VARCHAR` or integer types with values described in `COMMENT` |

---

## Table Acronyms

| Table | Acronym |
|---|---|
| `REF_CRASH_TYPE_TBL` | RCT |
| `REF_HARMFUL_EVENT_TBL` | RHE |
| `REF_WEATHER_CONDITION_TBL` | RWC |
| `REF_SURFACE_CONDITION_TBL` | RSC |
| `REF_PERSON_TYPE_TBL` | RPT |
| `REF_INJURY_STATUS_TBL` | RIS |
| `REF_BODY_TYPE_TBL` | RBT |
| `CRASH_TBL` | CRS |
| `VEHICLE_TBL` | VEH |
| `PERSON_TBL` | PRS |
| `ROADWAY_TBL` | RWY |
| `CRASH_WEATHER_CONDITION_TBL` | CWC |
| `CRASH_SURFACE_CONDITION_TBL` | CSC |
| `CRASH_CONTRIBUTING_ROADWAY_TBL` | CCR |
| `VEHICLE_TRAFFIC_CONTROL_TBL` | VTC |
| `VEHICLE_DAMAGE_AREA_TBL` | VDA |
| `VEHICLE_SEQUENCE_EVENT_TBL` | VSE |
| `PERSON_AIRBAG_TBL` | PAB |
| `PERSON_DRIVER_ACTION_TBL` | PDA |
| `PERSON_DL_RESTRICTION_TBL` | PDR |
| `PERSON_DRUG_TEST_RESULT_TBL` | DTR |
| `FATAL_SECTION_TBL` | FSC |
| `LARGE_VEHICLE_TBL` | LVH |
| `LV_SPECIAL_SIZING_TBL` | LVS |
| `NON_MOTORIST_TBL` | NMT |
| `NON_MOTORIST_SAFETY_EQUIPMENT_TBL` | NMS |
| `VEHICLE_AUTOMATION_TBL` | VAT |
| `VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL` | VAI |
| `VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL` | VAE |
| `APP_USER_TBL` | AUS |
| `CRASH_AUDIT_LOG_TBL` | CAL |

---

## Schema Overview

```
CRASH_TBL (central entity)
├── CRASH_WEATHER_CONDITION_TBL    (C11 - up to 4 per crash)
├── CRASH_SURFACE_CONDITION_TBL    (C13 - up to 4 per crash)
├── CRASH_CONTRIBUTING_ROADWAY_TBL (C14 - up to 2 per crash)
├── ROADWAY_TBL                    (R1-R16 - one per crash)
├── VEHICLE_TBL                    (V1-V24 - one per vehicle)
│   ├── VEHICLE_TRAFFIC_CONTROL_TBL    (V17 - up to 4 per vehicle)
│   ├── VEHICLE_DAMAGE_AREA_TBL        (V19 SF2 - up to 13 per vehicle)
│   ├── VEHICLE_SEQUENCE_EVENT_TBL     (V20 - up to 4 per vehicle)
│   ├── LARGE_VEHICLE_TBL              (LV1-LV11 - qualifying vehicles only)
│   │   └── LV_SPECIAL_SIZING_TBL      (LV8 SF2 - up to 4 per LV)
│   └── VEHICLE_AUTOMATION_TBL         (DV1 - vehicles with automation)
│       ├── VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL  (DV1 SF2 - up to 5)
│       └── VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL     (DV1 SF3 - up to 5)
└── PERSON_TBL                     (P1-P27 - one per person)
    ├── PERSON_AIRBAG_TBL              (P9 - up to 4 per person)
    ├── PERSON_DRIVER_ACTION_TBL       (P14 - up to 4 per driver)
    ├── PERSON_DL_RESTRICTION_TBL      (P16 SF1 - up to 3 per driver)
    ├── PERSON_DRUG_TEST_RESULT_TBL    (P23 SF3 - up to 4 per person)
    ├── FATAL_SECTION_TBL              (F1-F3 - fatal crashes only)
    └── NON_MOTORIST_TBL               (NM1-NM6 - non-motorists only)
        └── NON_MOTORIST_SAFETY_EQUIPMENT_TBL (NM5 - up to 5 per NM)

Reference Tables (no FK dependencies):
  REF_CRASH_TYPE_TBL
  REF_HARMFUL_EVENT_TBL
  REF_WEATHER_CONDITION_TBL
  REF_SURFACE_CONDITION_TBL
  REF_PERSON_TYPE_TBL
  REF_INJURY_STATUS_TBL
  REF_BODY_TYPE_TBL

Application Tables:
  APP_USER_TBL
  CRASH_AUDIT_LOG_TBL
```

---

## Setup Steps

### Step 1 — Connect to your MySQL database

```bash
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME>
```

Replace `<HOST>`, `<PORT>`, `<USERNAME>`, and `<DATABASE_NAME>` with your actual credentials.

---

### Step 2 — Verify you are using the correct database

```sql
SELECT DATABASE();
```

Confirm the output shows your intended database name before proceeding.

---

### Step 3 — Configure session settings

```sql
SET FOREIGN_KEY_CHECKS = 0;
SET sql_mode = 'STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
```

`FOREIGN_KEY_CHECKS = 0` allows tables to be created in any order. Re-enable it after all scripts run.

---

### Step 4 — Run all table scripts in numbered order

Scripts **must** be run in the numbered sequence shown below because later tables depend on earlier ones via foreign keys.

```bash
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 01_REF_CRASH_TYPE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 02_REF_HARMFUL_EVENT_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 03_REF_WEATHER_CONDITION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 04_REF_SURFACE_CONDITION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 05_REF_PERSON_TYPE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 06_REF_INJURY_STATUS_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 07_REF_BODY_TYPE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 08_CRASH_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 09_VEHICLE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 10_PERSON_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 11_ROADWAY_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 12_CRASH_WEATHER_CONDITION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 13_CRASH_SURFACE_CONDITION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 14_CRASH_CONTRIBUTING_ROADWAY_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 15_VEHICLE_TRAFFIC_CONTROL_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 16_VEHICLE_DAMAGE_AREA_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 17_VEHICLE_SEQUENCE_EVENT_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 18_PERSON_AIRBAG_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 19_PERSON_DRIVER_ACTION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 20_PERSON_DL_RESTRICTION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 21_PERSON_DRUG_TEST_RESULT_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 22_FATAL_SECTION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 23_LARGE_VEHICLE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 24_LV_SPECIAL_SIZING_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 25_NON_MOTORIST_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 26_NON_MOTORIST_SAFETY_EQUIPMENT_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 27_VEHICLE_AUTOMATION_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 28_VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 29_VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 30_APP_USER_TBL.sql
mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < 31_CRASH_AUDIT_LOG_TBL.sql
```

**Or run all at once using a shell loop** (Linux/macOS/Git Bash):

```bash
for f in $(ls database/tables/*.sql | sort); do
    mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < "$f"
done
```

---

### Step 5 — Re-enable foreign key checks

```sql
SET FOREIGN_KEY_CHECKS = 1;
```

---

### Step 6 — Verify all tables were created

```sql
SELECT TABLE_NAME, TABLE_COMMENT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = '<DATABASE_NAME>'
ORDER BY TABLE_NAME;
```

You should see all 31 tables.

---

### Step 7 — Verify reference data was loaded

```sql
SELECT 'REF_CRASH_TYPE_TBL'         AS TBL, COUNT(*) AS ROWS FROM REF_CRASH_TYPE_TBL         UNION ALL
SELECT 'REF_HARMFUL_EVENT_TBL',             COUNT(*)        FROM REF_HARMFUL_EVENT_TBL         UNION ALL
SELECT 'REF_WEATHER_CONDITION_TBL',         COUNT(*)        FROM REF_WEATHER_CONDITION_TBL     UNION ALL
SELECT 'REF_SURFACE_CONDITION_TBL',         COUNT(*)        FROM REF_SURFACE_CONDITION_TBL     UNION ALL
SELECT 'REF_PERSON_TYPE_TBL',               COUNT(*)        FROM REF_PERSON_TYPE_TBL           UNION ALL
SELECT 'REF_INJURY_STATUS_TBL',             COUNT(*)        FROM REF_INJURY_STATUS_TBL         UNION ALL
SELECT 'REF_BODY_TYPE_TBL',                 COUNT(*)        FROM REF_BODY_TYPE_TBL;
```

Expected row counts: 7, 51, 12, 9, 10, 5, 29.

---

### Step 8 — Verify foreign key constraints

```sql
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = '<DATABASE_NAME>'
ORDER BY TABLE_NAME;
```

---

## Audit Column Usage

Every table includes these five columns, prefixed with the table's 3-letter acronym:

| Column | Type | Purpose |
|---|---|---|
| `XXX_CREATED_BY` | `VARCHAR(100) NOT NULL` | Username or service account that inserted the row |
| `XXX_CREATED_DT` | `DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP` | Row insertion timestamp |
| `XXX_MODIFIED_BY` | `VARCHAR(100) NULL` | Username or service account that last updated the row |
| `XXX_MODIFIED_DT` | `DATETIME NULL` | Last update timestamp (set by application layer, not DB trigger) |
| `XXX_LAST_UPDATED_ACTIVITY_CODE` | `VARCHAR(20) NOT NULL` | Activity that caused the change: `CREATE`, `UPDATE`, `IMPORT`, `CORRECT`, `REVIEW` |

The Spring Boot service layer is responsible for populating `MODIFIED_BY` and `MODIFIED_DT` on every UPDATE statement. The `CRASH_AUDIT_LOG_TBL` captures full before/after JSON for every write operation.

---

## Test Data Seed Script

`test-data/seed_crashes.sql` inserts **8 realistic sample crash records** (case numbers `TEST-001` through `TEST-008`) so the UI crash list and crash detail views have data to display immediately after setup.

The script is **idempotent** — it deletes any existing `TEST-*` records (cascade removes all child rows) before inserting, so it is safe to re-run at any time without duplicating data.

### What it seeds

| Case # | Date | County | Scenario | Severity | Vehicles |
|---|---|---|---|---|---|
| TEST-001 | 2024-07-15 | Hillsborough (Manchester) | Fatal rear-end, I-93 | Fatal (1) | 2 |
| TEST-002 | 2024-08-22 | Rockingham (Portsmouth) | Angle collision, signalized intersection | Serious Injury | 2 |
| TEST-003 | 2024-09-10 | Carroll (Conway) | Single vehicle rollover, rain + fog | Minor Injury | 1 |
| TEST-004 | 2024-10-05 | Carroll (Hart's Location) | Head-on, dark road, Crawford Notch | Fatal (1) | 2 |
| TEST-005 | 2024-11-12 | Hillsborough (Nashua) | PDO rear-end, US-3 Turnpike | PDO | 2 |
| TEST-006 | 2024-11-28 | Merrimack (Concord) | Sideswipe, nighttime, NH-9 | Possible Injury | 2 |
| TEST-007 | 2025-01-08 | Rockingham (Hampton) | Work zone, pedestrian involved, I-95 | Serious Injury | 2 |
| TEST-008 | 2025-02-03 | Belknap (Laconia) | 3-vehicle chain, snow + ice, NH-11 | Minor Injury | 3 |

Child data included per crash: 13 vehicles, 8 roadway records, 10 weather conditions, 9 surface conditions, 11 vehicle sequence events, 22 vehicle damage areas, 4 traffic controls, 26 persons (drivers, passengers, 1 pedestrian), 11 driver actions, 2 fatal sections, 1 non-motorist record.

### How to run

```bash
mysql -u <USERNAME> -p <DATABASE_NAME> < test-data/seed_crashes.sql
```

### To remove test data

```sql
DELETE FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER LIKE 'TEST-%';
-- Cascade deletes all child records automatically
```

---

## Drop All Tables (if re-running from scratch)

Run this **only** in a development or test environment. Tables must be dropped in reverse dependency order.

```sql
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS CRASH_AUDIT_LOG_TBL;
DROP TABLE IF EXISTS APP_USER_TBL;
DROP TABLE IF EXISTS VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL;
DROP TABLE IF EXISTS VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL;
DROP TABLE IF EXISTS VEHICLE_AUTOMATION_TBL;
DROP TABLE IF EXISTS NON_MOTORIST_SAFETY_EQUIPMENT_TBL;
DROP TABLE IF EXISTS NON_MOTORIST_TBL;
DROP TABLE IF EXISTS LV_SPECIAL_SIZING_TBL;
DROP TABLE IF EXISTS LARGE_VEHICLE_TBL;
DROP TABLE IF EXISTS FATAL_SECTION_TBL;
DROP TABLE IF EXISTS PERSON_DRUG_TEST_RESULT_TBL;
DROP TABLE IF EXISTS PERSON_DL_RESTRICTION_TBL;
DROP TABLE IF EXISTS PERSON_DRIVER_ACTION_TBL;
DROP TABLE IF EXISTS PERSON_AIRBAG_TBL;
DROP TABLE IF EXISTS VEHICLE_SEQUENCE_EVENT_TBL;
DROP TABLE IF EXISTS VEHICLE_DAMAGE_AREA_TBL;
DROP TABLE IF EXISTS VEHICLE_TRAFFIC_CONTROL_TBL;
DROP TABLE IF EXISTS CRASH_CONTRIBUTING_ROADWAY_TBL;
DROP TABLE IF EXISTS CRASH_SURFACE_CONDITION_TBL;
DROP TABLE IF EXISTS CRASH_WEATHER_CONDITION_TBL;
DROP TABLE IF EXISTS ROADWAY_TBL;
DROP TABLE IF EXISTS PERSON_TBL;
DROP TABLE IF EXISTS VEHICLE_TBL;
DROP TABLE IF EXISTS CRASH_TBL;
DROP TABLE IF EXISTS REF_BODY_TYPE_TBL;
DROP TABLE IF EXISTS REF_INJURY_STATUS_TBL;
DROP TABLE IF EXISTS REF_PERSON_TYPE_TBL;
DROP TABLE IF EXISTS REF_SURFACE_CONDITION_TBL;
DROP TABLE IF EXISTS REF_WEATHER_CONDITION_TBL;
DROP TABLE IF EXISTS REF_HARMFUL_EVENT_TBL;
DROP TABLE IF EXISTS REF_CRASH_TYPE_TBL;
SET FOREIGN_KEY_CHECKS = 1;
```
