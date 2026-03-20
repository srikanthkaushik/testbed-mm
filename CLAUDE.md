# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Reference Document

This repository is associated with the **MMUCC (Model Minimum Uniform Crash Criteria) 5th Edition** specification (`MMUCC-v5.pdf`). This PDF defines 115 data elements across 8 sections used to standardize motor vehicle crash data collection across U.S. jurisdictions.

## Tech Stack

- **Frontend:** Angular (micro-frontends)
- **Backend:** Spring Boot (microservices)
- **Primary Database:** MySQL 8.0
- **Secondary Database:** Oracle 19c

## Project Status

Database schema is complete. Backend auth-service and crash-service are fully implemented (Sprints 1–4). Frontend is functionally complete for data entry and record management:

- **Phases 1–8 complete:** login, crash list, crash detail (read-only, all 115 fields), crash entry form, vehicle entry form, person entry form (P1–P27 with conditional Fatal/Non-Motorist sub-sections), roadway entry form (R1–R16), vehicle automation form (DV1), large vehicle form (LV1–LV11), delete operations (crash/vehicle/person with inline confirmation), dashboard (stat cards + recent crashes), admin user management (user list + inline role editing).
- **All 115 MMUCC data elements are readable and writable** via the frontend.
- **Remaining:** reports/export (CSV/PDF) — depends on report-service which is not yet built.

## Repository Structure

```
database/
├── mysql/
│   ├── README.md               -- Setup guide and verification steps
│   └── 01_*.sql – 31_*.sql    -- Table DDL + reference data INSERTs
└── oracle/
    ├── README.md               -- Setup guide and Oracle-specific notes
    └── 01_*.sql – 26_*.sql    -- Table DDL + lookup data INSERTs
```

## Database Architecture

### MySQL Schema (31 tables)

Central entity is `CRASH_TBL`. All other tables cascade-delete from it.

**Reference tables** (no FK dependencies, pre-loaded with MMUCC coded values):
`REF_CRASH_TYPE_TBL`, `REF_HARMFUL_EVENT_TBL`, `REF_WEATHER_CONDITION_TBL`, `REF_SURFACE_CONDITION_TBL`, `REF_PERSON_TYPE_TBL`, `REF_INJURY_STATUS_TBL`, `REF_BODY_TYPE_TBL`

**MMUCC data tables** follow the hierarchy:
- `CRASH_TBL` → `VEHICLE_TBL` → `PERSON_TBL` (core chain)
- `ROADWAY_TBL` (1:1 with crash)
- Multi-value child tables for fields that allow "select 1–N": `CRASH_WEATHER_CONDITION_TBL`, `CRASH_SURFACE_CONDITION_TBL`, `CRASH_CONTRIBUTING_ROADWAY_TBL`, `VEHICLE_TRAFFIC_CONTROL_TBL`, `VEHICLE_DAMAGE_AREA_TBL`, `VEHICLE_SEQUENCE_EVENT_TBL`, `PERSON_AIRBAG_TBL`, `PERSON_DRIVER_ACTION_TBL`, `PERSON_DL_RESTRICTION_TBL`, `PERSON_DRUG_TEST_RESULT_TBL`
- Conditional sections (only for qualifying records): `FATAL_SECTION_TBL`, `NON_MOTORIST_TBL`, `LARGE_VEHICLE_TBL`, `LV_SPECIAL_SIZING_TBL`, `NON_MOTORIST_SAFETY_EQUIPMENT_TBL`
- Automation tables: `VEHICLE_AUTOMATION_TBL`, `VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL`, `VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL`

**Application tables:** `APP_USER_TBL`, `CRASH_AUDIT_LOG_TBL`

### Oracle Schema (26 tables)

Equivalent schema for Oracle 19c. Key differences from MySQL:
- The 7 MySQL `REF_*` tables are replaced by two consolidated lookup tables: `LOOKUP_CODE_TYPES_TBL` and `LOOKUP_CODE_VALUES_TBL`
- Data types: `NUMBER`, `VARCHAR2`, `DATE`, `CLOB` only (no MySQL-specific types)
- PKs use `GENERATED ALWAYS AS IDENTITY`
- JSON audit log columns stored as `CLOB`
- `COMMENT ON TABLE` / `COMMENT ON COLUMN` as separate DDL statements

### Naming Conventions (both databases)

| Convention | Rule |
|---|---|
| Table names | UPPERCASE with `_TBL` suffix |
| Column names | UPPERCASE with 3-letter table acronym prefix + underscore (e.g., `CRS_CRASH_DATE`) |
| Coded value columns | Integer type; valid values documented in column `COMMENT` (MySQL) or `COMMENT ON COLUMN` (Oracle) |
| Audit columns | Every table has 5 audit columns prefixed with the table acronym: `XXX_CREATED_BY`, `XXX_CREATED_DT`, `XXX_MODIFIED_BY`, `XXX_MODIFIED_DT`, `XXX_LAST_UPDATED_ACTIVITY_CODE` |
| No ENUM | All coded/status columns use integer or VARCHAR types, never ENUM |

### Audit Column Activity Codes

`CREATE`, `UPDATE`, `IMPORT`, `CORRECT`, `REVIEW`

The Spring Boot service layer is responsible for populating `MODIFIED_BY` and `MODIFIED_DT` on every UPDATE. `CRASH_AUDIT_LOG_TBL` captures full before/after JSON for every write operation (append-only).

## MMUCC Data Element Coverage

| Section | Elements | Primary Table(s) |
|---|---|---|
| Crash (C) | C1–C27 | `CRASH_TBL` + 3 child tables |
| Vehicle (V) | V1–V24 | `VEHICLE_TBL` + 5 child tables |
| Person (P) | P1–P27 | `PERSON_TBL` + 4 child tables |
| Roadway (R) | R1–R16 | `ROADWAY_TBL` |
| Fatal (F) | F1–F3 | `FATAL_SECTION_TBL` |
| Large Vehicle/HazMat (LV) | LV1–LV11 | `LARGE_VEHICLE_TBL` + `LV_SPECIAL_SIZING_TBL` |
| Non-Motorist (NM) | NM1–NM6 | `NON_MOTORIST_TBL` + `NON_MOTORIST_SAFETY_EQUIPMENT_TBL` |
| Dynamic/Automation (DV) | DV1 | `VEHICLE_AUTOMATION_TBL` + 2 child tables |
