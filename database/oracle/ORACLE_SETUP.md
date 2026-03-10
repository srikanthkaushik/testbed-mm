# MMUCC v5 Oracle 19c Database Setup Guide

## Prerequisites

- Oracle 19c (or compatible Oracle Database 19c instance)
- A schema/user has already been created with CREATE TABLE, CREATE INDEX, ALTER TABLE, CREATE SEQUENCE privileges
- SQL*Plus or SQLcl available, or a compatible Oracle IDE (SQL Developer, DBeaver, etc.)

---

## Key Differences from MySQL Version

| Aspect | MySQL | Oracle 19c |
|---|---|---|
| Reference tables | 7 individual `REF_*` tables | 2 consolidated lookup tables |
| Auto-increment PK | `AUTO_INCREMENT` | `GENERATED ALWAYS AS IDENTITY` |
| Timestamp default | `DEFAULT CURRENT_TIMESTAMP` | `DEFAULT SYSDATE` |
| String type | `VARCHAR` | `VARCHAR2` |
| Integer types | `TINYINT`, `SMALLINT`, `INT`, `BIGINT` | `NUMBER(3)`, `NUMBER(5)`, `NUMBER(10)`, `NUMBER(20)` |
| Decimal type | `DECIMAL(p,s)` | `NUMBER(p,s)` |
| Date+time type | `DATETIME` | `DATE` (Oracle DATE includes time component) |
| Year-only | `YEAR` | `NUMBER(4)` |
| Time-only | `TIME` | `VARCHAR2(5)` (HH:MM format) |
| Long text / JSON | `TEXT`, `LONGTEXT`, `JSON` | `CLOB` |
| Index definition | Inline in `CREATE TABLE` | Standalone `CREATE INDEX` |
| Foreign keys | Inline in `CREATE TABLE` | `ALTER TABLE ADD CONSTRAINT` |
| Column comments | Inline `COMMENT` clause | `COMMENT ON COLUMN` DDL statement |
| Table comment | Inline `COMMENT=` | `COMMENT ON TABLE` DDL statement |
| Case sensitivity | Case-insensitive identifiers | Unquoted identifiers stored as UPPERCASE |

---

## Lookup Table Design

Instead of 7 separate MySQL reference tables, Oracle uses two consolidated lookup tables:

### LOOKUP_CODE_TYPES_TBL (LCT)
Defines each category of reference data. One row per category type.

| LCT_TYPE_CODE | Purpose |
|---|---|
| `CRASH_TYPE` | MMUCC C2 SF1 – Crash Classification |
| `HARMFUL_EVENT` | MMUCC C7/V20/V21 – First Harmful Event and Sequence of Events |
| `WEATHER_CONDITION` | MMUCC C11 – Weather Conditions |
| `SURFACE_CONDITION` | MMUCC C13 – Roadway Surface Condition |
| `PERSON_TYPE` | MMUCC P4 SF1 – Person Type |
| `INJURY_STATUS` | MMUCC P5 – Injury Status (KABCO) |
| `BODY_TYPE` | MMUCC V8 SF1 – Motor Vehicle Body Type Category |

The `LCT_FIELD_1_DESC` through `LCT_FIELD_5_DESC` columns describe what each `FIELD_1`–`FIELD_5` value in `LOOKUP_CODE_VALUES_TBL` represents for that type.

### LOOKUP_CODE_VALUES_TBL (LCV)
Stores all coded values for all types. Query pattern: `WHERE LCV_TYPE_CODE = 'INJURY_STATUS' AND LCV_VALUE_CODE = '1'`.

- `LCV_VALUE_CODE` — the MMUCC numeric code stored as a string (e.g., `'1'`, `'99'`)
- `LCV_FIELD_1` — long description (populated for all rows)
- `LCV_FIELD_2` through `LCV_FIELD_5` — additional attributes (see `LCT_FIELD_x_DESC` for meaning per type)

Example — INJURY_STATUS values:

| LCV_VALUE_CODE | LCV_FIELD_1 | LCV_FIELD_2 (KABCO) | LCV_FIELD_3 (Req. Fatal Sec.) |
|---|---|---|---|
| 1 | (K) Fatal Injury | K | Y |
| 2 | (A) Suspected Serious Injury | A | N |

---

## Table Acronyms

| Table | Acronym |
|---|---|
| `LOOKUP_CODE_TYPES_TBL` | LCT |
| `LOOKUP_CODE_VALUES_TBL` | LCV |
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
LOOKUP_CODE_TYPES_TBL  (no FK dependencies)
└── LOOKUP_CODE_VALUES_TBL  (FK to LOOKUP_CODE_TYPES_TBL)

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

Application Tables (no MMUCC FK dependencies):
  APP_USER_TBL
  CRASH_AUDIT_LOG_TBL
```

---

## Setup Steps

### Step 1 — Connect to your Oracle schema

```bash
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME>
```

Or using SQLcl:
```bash
sql <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME>
```

---

### Step 2 — Verify you are connected to the correct schema

```sql
SELECT USER, SYS_CONTEXT('USERENV', 'DB_NAME') AS DB_NAME FROM DUAL;
```

---

### Step 3 — Configure session settings

```sql
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
```

This ensures DATE values display with both date and time components.

---

### Step 4 — Run all table scripts in numbered order

Scripts must be run in the numbered sequence shown below because later tables depend on earlier ones via foreign keys.

```bash
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @01_LOOKUP_CODE_TYPES_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @02_LOOKUP_CODE_VALUES_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @03_CRASH_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @04_VEHICLE_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @05_PERSON_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @06_ROADWAY_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @07_CRASH_WEATHER_CONDITION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @08_CRASH_SURFACE_CONDITION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @09_CRASH_CONTRIBUTING_ROADWAY_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @10_VEHICLE_TRAFFIC_CONTROL_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @11_VEHICLE_DAMAGE_AREA_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @12_VEHICLE_SEQUENCE_EVENT_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @13_PERSON_AIRBAG_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @14_PERSON_DRIVER_ACTION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @15_PERSON_DL_RESTRICTION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @16_PERSON_DRUG_TEST_RESULT_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @17_FATAL_SECTION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @18_LARGE_VEHICLE_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @19_LV_SPECIAL_SIZING_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @20_NON_MOTORIST_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @21_NON_MOTORIST_SAFETY_EQUIPMENT_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @22_VEHICLE_AUTOMATION_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @23_VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @24_VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @25_APP_USER_TBL.sql
sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @26_CRASH_AUDIT_LOG_TBL.sql
```

**Or run all at once using a shell loop** (Linux/macOS/Git Bash from the oracle directory):

```bash
for f in $(ls database/oracle/*.sql | sort); do
    sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @"$f"
done
```

---

### Step 5 — Verify all tables were created

```sql
SELECT TABLE_NAME
FROM USER_TABLES
WHERE TABLE_NAME LIKE '%_TBL'
ORDER BY TABLE_NAME;
```

You should see all 26 tables.

---

### Step 6 — Verify reference data was loaded

```sql
SELECT LCV_TYPE_CODE, COUNT(*) AS ROW_COUNT
FROM LOOKUP_CODE_VALUES_TBL
GROUP BY LCV_TYPE_CODE
ORDER BY LCV_TYPE_CODE;
```

Expected results:

| LCV_TYPE_CODE | ROW_COUNT |
|---|---|
| BODY_TYPE | 29 |
| CRASH_TYPE | 7 |
| HARMFUL_EVENT | 51 |
| INJURY_STATUS | 5 |
| PERSON_TYPE | 10 |
| SURFACE_CONDITION | 9 |
| WEATHER_CONDITION | 12 |

---

### Step 7 — Verify foreign key constraints

```sql
SELECT TABLE_NAME, CONSTRAINT_NAME, R_CONSTRAINT_NAME
FROM USER_CONSTRAINTS
WHERE CONSTRAINT_TYPE = 'R'
ORDER BY TABLE_NAME;
```

---

### Step 8 — Verify indexes

```sql
SELECT TABLE_NAME, INDEX_NAME, UNIQUENESS
FROM USER_INDEXES
WHERE TABLE_NAME LIKE '%_TBL'
ORDER BY TABLE_NAME, INDEX_NAME;
```

---

## Audit Column Usage

Every table includes these five columns, prefixed with the table's 3-letter acronym:

| Column | Type | Purpose |
|---|---|---|
| `XXX_CREATED_BY` | `VARCHAR2(100) NOT NULL` | Username or service account that inserted the row |
| `XXX_CREATED_DT` | `DATE DEFAULT SYSDATE NOT NULL` | Row insertion timestamp |
| `XXX_MODIFIED_BY` | `VARCHAR2(100)` | Username or service account that last updated the row |
| `XXX_MODIFIED_DT` | `DATE` | Last update timestamp (set by application layer) |
| `XXX_LAST_UPDATED_ACTIVITY_CODE` | `VARCHAR2(20) NOT NULL` | Activity that caused the change: `CREATE`, `UPDATE`, `IMPORT`, `CORRECT`, `REVIEW` |

---

## Drop All Tables (if re-running from scratch)

Run this **only** in a development or test environment. Tables must be dropped in reverse dependency order.

```sql
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE CRASH_AUDIT_LOG_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE APP_USER_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_AUTOMATION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE NON_MOTORIST_SAFETY_EQUIPMENT_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE NON_MOTORIST_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE LV_SPECIAL_SIZING_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE LARGE_VEHICLE_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE FATAL_SECTION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSON_DRUG_TEST_RESULT_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSON_DL_RESTRICTION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSON_DRIVER_ACTION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSON_AIRBAG_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_SEQUENCE_EVENT_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_DAMAGE_AREA_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_TRAFFIC_CONTROL_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE CRASH_CONTRIBUTING_ROADWAY_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE CRASH_SURFACE_CONDITION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE CRASH_WEATHER_CONDITION_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE ROADWAY_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE PERSON_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE VEHICLE_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE CRASH_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE LOOKUP_CODE_VALUES_TBL CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE LOOKUP_CODE_TYPES_TBL CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('All tables dropped successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
```
