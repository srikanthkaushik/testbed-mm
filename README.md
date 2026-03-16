# MMUCC v5 Crash Data Management System

A web application for collecting, managing, and reporting motor vehicle crash data in compliance with the **Model Minimum Uniform Crash Criteria (MMUCC) 5th Edition** standard.

---

## Overview

MMUCC is a voluntary national guideline that defines a minimum set of 115 data elements for standardizing crash data collection across U.S. state and local jurisdictions. This system provides a structured data entry, review, and reporting platform built on top of the MMUCC v5 specification.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Angular (micro-frontends) |
| Backend | Spring Boot (microservices) |
| Primary Database | MySQL 8.0 |
| Secondary Database | Oracle 19c |

---

## Project Status

> **Phase: Backend Sprints 1–3 Complete — Frontend Sprints 1–5 Complete**

- [x] MMUCC v5 specification analysis
- [x] MySQL 8.0 schema — 31 tables covering all 115 MMUCC data elements
- [x] Oracle 19c schema — 26 tables with consolidated lookup table design
- [x] Spring Boot microservices — auth-service and crash-service complete
  - [x] auth-service — Firebase SSO, JWT + HttpOnly refresh-token rotation, user CRUD, RBAC (`ADMIN` / `DATA_ENTRY` / `ANALYST` / `VIEWER`)
  - [x] crash-service — full CRUD for crashes, vehicles, roadway, and all 6 multi-value child tables; Flyway migrations; Testcontainers integration tests
  - [x] crash-service — Person (P1–P27), Fatal Section, Non-Motorist, Large Vehicle/HazMat, Vehicle Automation; 28 integration tests passing
  - [ ] reference-service, audit enhancements, MMUCC validation rules — Sprint 4
  - [ ] report-service, CSV/Excel export — Sprint 5
- [x] Angular frontend — Sprints 1–5 complete
  - [x] Login page — ADA/WCAG 2.1 AA compliant, Google SSO + email/password
  - [x] Authenticated shell — responsive nav, collapsible sidebar, role-aware links
  - [x] Crash list — filters, sort, pagination, URL state sync, skeleton shimmer
  - [x] Crash detail — tabbed view (Overview, Vehicles, Roadway, Audit), stats strip
  - [ ] Crash entry form, vehicle form, admin, reports — Sprint 4+
- [x] Authentication and authorization — JWT in-memory, HttpOnly refresh cookie, RBAC enforced at controller level
- [x] Test data seed script — 8 realistic crash records with vehicles, roadway, weather/surface conditions
- [ ] Reporting and data export

---

## MMUCC Data Element Coverage

The schema covers all 8 MMUCC v5 sections:

| Section | Elements | Description |
|---|---|---|
| Crash (C) | C1–C27 | Core crash attributes, location, conditions, severity |
| Vehicle (V) | V1–V24 | Vehicle identification, configuration, damage, maneuver |
| Person (P) | P1–P27 | Occupant/non-motorist demographics, injury, impairment |
| Roadway (R) | R1–R16 | Roadway geometry, traffic volumes, pavement markings |
| Fatal Section (F) | F1–F3 | Additional data required for fatal crashes only |
| Large Vehicle & HazMat (LV) | LV1–LV11 | CMV/large vehicle, carrier, cargo, HazMat details |
| Non-Motorist (NM) | NM1–NM6 | Pedestrian/cyclist actions, location, safety equipment |
| Dynamic/Automation (DV) | DV1 | SAE J3016 automation levels present and engaged |

---

## Repository Structure

```
mmucc-develop/
├── MMUCC-v5.pdf                  Reference specification document
├── CLAUDE.md                     AI assistant guidance for this repo
├── README.md                     This file
├── backend/
│   ├── README.md                 Backend architecture and sprint plan
│   ├── CRASH.md                  crash-service API reference
│   ├── common/                   Shared DTOs, exceptions, audit utilities
│   ├── auth-service/             Firebase → JWT authentication (port 8081)
│   └── crash-service/            Crash/Vehicle/Roadway CRUD (port 8082)
├── frontend/
│   ├── README.md                 Frontend architecture and sprint plan
│   ├── mockup/                   Balsamiq-style HTML wireframes (7 screens)
│   └── mmucc-app/                Angular 17 application
└── database/
    ├── mysql/
    │   ├── README.md             MySQL setup and verification guide
    │   ├── 01_REF_CRASH_TYPE_TBL.sql
    │   ├── 02_REF_HARMFUL_EVENT_TBL.sql
    │   ├── ...                   (31 SQL files total)
    │   ├── 31_CRASH_AUDIT_LOG_TBL.sql
    │   └── test-data/
    │       └── seed_crashes.sql  Idempotent seed: 8 sample crashes with vehicles/roadway/conditions
    └── oracle/
        ├── README.md             Oracle 19c setup and verification guide
        ├── 01_LOOKUP_CODE_TYPES_TBL.sql
        ├── 02_LOOKUP_CODE_VALUES_TBL.sql
        ├── ...                   (26 SQL files total)
        └── 26_CRASH_AUDIT_LOG_TBL.sql
```

---

## Database Setup

### MySQL

See [`database/mysql/README.md`](database/mysql/README.md) for full instructions. Summary:

1. Create a database and note the credentials
2. Run the 31 SQL scripts in numbered order
3. Verify 31 tables are created and reference data is loaded

```bash
for f in $(ls database/mysql/*.sql | sort); do
    mysql -h <HOST> -P <PORT> -u <USERNAME> -p <DATABASE_NAME> < "$f"
done
```

### Oracle 19c

See [`database/oracle/README.md`](database/oracle/README.md) for full instructions. Summary:

1. Connect to an existing Oracle schema with CREATE TABLE / CREATE INDEX / ALTER TABLE privileges
2. Run the 26 SQL scripts in numbered order

```bash
for f in $(ls database/oracle/*.sql | sort); do
    sqlplus <USERNAME>/<PASSWORD>@<HOST>:<PORT>/<SERVICE_NAME> @"$f"
done
```

---

## Database Design Principles

- **Central entity:** `CRASH_TBL` — all tables reference it; cascade-delete propagates to all child records
- **Multi-value fields:** MMUCC elements that allow "select 1–N" responses are stored in separate child tables (e.g., `CRASH_WEATHER_CONDITION_TBL` for up to 4 weather conditions per crash) rather than repeating columns
- **Conditional sections:** Fatal, Large Vehicle, and Non-Motorist sections exist as separate optional tables populated only when the triggering condition is met
- **No ENUM types:** Coded value columns use integer or VARCHAR types; all valid values are documented in column comments
- **Audit trail:** Every table carries 5 audit columns (`XXX_CREATED_BY`, `XXX_CREATED_DT`, `XXX_MODIFIED_BY`, `XXX_MODIFIED_DT`, `XXX_LAST_UPDATED_ACTIVITY_CODE`). `CRASH_AUDIT_LOG_TBL` captures full before/after JSON snapshots for every write operation.
- **Oracle lookup tables:** The 7 MySQL reference tables are consolidated into `LOOKUP_CODE_TYPES_TBL` and `LOOKUP_CODE_VALUES_TBL` to reduce schema object count and simplify maintenance

---

## Planned Application Roles

| Role | Access |
|---|---|
| `ADMIN` | Full system administration, user management |
| `DATA_ENTRY` | Create and edit crash records |
| `ANALYST` | Read-only access, reporting and exports |
| `VIEWER` | Read-only access to crash records |

---

## Reference

- [MMUCC 5th Edition (2017) — NHTSA](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/812433)
