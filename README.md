# MMUCC v5 Crash Reporting System

A full-stack web application for collecting, managing, and reporting motor vehicle crash data in compliance with the **Model Minimum Uniform Crash Criteria (MMUCC) 5th Edition** standard. Covers all 115 data elements across 8 sections.

---

## Project Status — March 2026

### Backend

| Sprint | Scope | Status |
|---|---|---|
| **Sprint 1** | auth-service — Firebase login, JWT, refresh-token rotation, RBAC, Testcontainers tests | ✅ Complete |
| **Sprint 2** | crash-service — Crash + Vehicle + Roadway CRUD, all 6 multi-value child tables, Flyway schema, integration tests | ✅ Complete |
| **Sprint 3** | crash-service — Person (P1–P27), Fatal Section, Non-Motorist, Large Vehicle/HazMat, Vehicle Automation; 28 integration tests | ✅ Complete |
| **Sprint 4** | Audit log timeline enhancements, MMUCC validation rules (V-01–V-14) | ✅ Complete |
| **Sprint 5** | reference-service (lookup codes API) | 🔲 Not started |
| **Sprint 6** | report-service, CSV/Excel export | 🔲 Not started |

### Frontend

| Phase | Scope | Status |
|---|---|---|
| **Phase 1** | Login, shell, crash list (filters, sort, pagination, URL state) | ✅ Complete |
| **Phase 2** | Crash detail — tabbed read-only view (Overview, Vehicles, Persons, Roadway, Audit) | ✅ Complete |
| **Phase 3** | Crash detail — all 115 MMUCC fields displayed with "N — Description" lookup rendering | ✅ Complete |
| **Phase 4** | Crash entry form (C1–C27) — create and edit crash records | ✅ Complete |
| **Phase 5** | Vehicle entry form (V1–V24) — add and edit vehicles on a crash | ✅ Complete |
| **Phase 6** | Person entry form (P1–P27) | 🔲 Not started |
| **Phase 7** | Roadway entry form (R1–R16) | 🔲 Not started |
| **Phase 8** | Dashboard, reports, admin | 🔲 Not started |

### MMUCC Coverage Summary

| Section | Elements | Backend | UI Read | UI Write |
|---|---|---|---|---|
| Crash (C) | C1–C27 | ✅ | ✅ | ✅ |
| Vehicle (V) | V1–V24 | ✅ | ✅ | ✅ |
| Person (P) | P1–P27 | ✅ | ✅ | 🔲 |
| Roadway (R) | R1–R16 | ✅ | ✅ | 🔲 |
| Fatal (F) | F1–F3 | ✅ | ✅ | 🔲 |
| Large Vehicle / HazMat (LV) | LV1–LV11 | ✅ | ✅ | 🔲 |
| Non-Motorist (NM) | NM1–NM6 | ✅ | ✅ | 🔲 |
| Dynamic / Automation (DV) | DV1 | ✅ | ✅ | 🔲 |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Angular 18 (standalone components, signals, lazy-loaded routes) |
| Backend | Spring Boot 3.x microservices (Maven multi-module) |
| Auth | Firebase Authentication + internal HS256 JWT (15 min) + HttpOnly refresh cookie |
| Primary DB | MySQL 8.0 (Flyway-managed migrations) |
| Secondary DB | Oracle 19c |
| ORM / Mapping | Spring Data JPA + MapStruct |
| API Docs | SpringDoc OpenAPI / Swagger UI (per service) |
| Integration Tests | Testcontainers (real MySQL 8.0 in Docker) |

---

## Repository Structure

```
mmucc-develop/
├── README.md                     This file
├── CLAUDE.md                     AI assistant guidance for this repo
├── MMUCC-v5.pdf                  Reference specification document
│
├── database/
│   ├── mysql/
│   │   ├── README.md             MySQL setup and verification guide
│   │   ├── 01_*.sql – 31_*.sql   Table DDL + reference data INSERTs (31 files)
│   │   └── test-data/
│   │       └── seed_crashes.sql  Idempotent seed: 8 sample crashes, 13 vehicles, 26 persons
│   └── oracle/
│       ├── README.md             Oracle 19c setup guide and key differences
│       └── 01_*.sql – 26_*.sql   Table DDL (consolidated lookup design, 26 files)
│
├── backend/
│   ├── README.md                 Architecture, sprint plan, technical decisions
│   ├── AUTH.md                   auth-service API, token design, configuration
│   ├── CRASH.md                  crash-service API reference, data model, migrations
│   ├── pom.xml                   Maven parent aggregator (multi-module)
│   ├── common/                   Shared library: JwtUtils, AuditFields, exceptions
│   ├── auth-service/             Port 8081 — Firebase → JWT, user CRUD, RBAC
│   └── crash-service/            Port 8082 — All MMUCC CRUD, Flyway, 28 integration tests
│
└── frontend/
    └── mmucc-app/
        ├── README.md             Angular app architecture, routes, local dev guide
        └── src/app/
            ├── core/             Services, models, guards, auth interceptor
            ├── features/         crashes/ (list, detail, crash-form, vehicle-form)
            └── shared/           Alert component, shared styles
```

---

## Quick Start

### 1. Database (MySQL)

```bash
# Run all 31 table scripts in numbered order
cd database/mysql
for f in $(ls *.sql | sort); do
    mysql -u <USERNAME> -p <DATABASE_NAME> < "$f"
done

# Load 8 sample crashes (optional but recommended for dev)
mysql -u <USERNAME> -p <DATABASE_NAME> < test-data/seed_crashes.sql
```

See [`database/mysql/README.md`](database/mysql/README.md) for complete setup and verification steps.

### 2. Backend

```bash
cd backend

export MMUCC_DB_USER=mmucc_app
export MMUCC_DB_PASSWORD=changeme_local
export MMUCC_JWT_SECRET=bG9jYWxkZXZzZWNyZXRsb2NhbGRldnNlY3JldGxvY2FsZGV2c2VjcmV0bG9jYQ==
export FIREBASE_SERVICE_ACCOUNT_PATH=$HOME/.mmucc/firebase-service-account.json

# auth-service  →  http://localhost:8081
mvn spring-boot:run -pl auth-service -am -Dspring-boot.run.profiles=local

# crash-service  →  http://localhost:8082  (separate terminal)
mvn spring-boot:run -pl crash-service -am -Dspring-boot.run.profiles=local
```

### 3. Frontend

```bash
cd frontend/mmucc-app
npm install
ng serve            # http://localhost:4200
```

Login via the Firebase-backed login page. New accounts are auto-provisioned as `VIEWER`; an `ADMIN` must grant `DATA_ENTRY` or `ADMIN` role to create and edit crash records.

---

## Application Roles

| Role | GET | POST / PUT | DELETE | Admin |
|---|---|---|---|---|
| `VIEWER` | ✓ | — | — | — |
| `ANALYST` | ✓ | — | — | — |
| `DATA_ENTRY` | ✓ | ✓ | — | — |
| `ADMIN` | ✓ | ✓ | ✓ | ✓ |

---

## Database Design Principles

- **Central entity:** `CRASH_TBL` — all tables cascade-delete from it
- **Multi-value fields:** MMUCC elements allowing "select 1–N" are in dedicated child tables (e.g., `CRASH_WEATHER_CONDITION_TBL`)
- **Conditional sections:** Fatal, Large Vehicle, Non-Motorist sections are optional child tables populated only when the qualifying condition is met
- **No ENUM types:** All coded columns use integer or VARCHAR; valid values documented in column `COMMENT`
- **Audit trail:** Every table has 5 audit columns (`XXX_CREATED_BY/DT`, `XXX_MODIFIED_BY/DT`, `XXX_LAST_UPDATED_ACTIVITY_CODE`). `CRASH_AUDIT_LOG_TBL` stores full before/after JSON for every write.
- **Oracle design:** The 7 MySQL `REF_*` tables are consolidated into `LOOKUP_CODE_TYPES_TBL` + `LOOKUP_CODE_VALUES_TBL`

---

## Further Reading

- [`backend/README.md`](backend/README.md) — service decomposition, sprint history, key decisions
- [`backend/AUTH.md`](backend/AUTH.md) — auth-service API, token design, roles, security notes
- [`backend/CRASH.md`](backend/CRASH.md) — crash-service API reference, multi-value child pattern, Flyway history
- [`database/mysql/README.md`](database/mysql/README.md) — MySQL schema setup, table acronyms, seed data
- [`database/oracle/README.md`](database/oracle/README.md) — Oracle schema, consolidated lookup design
- [`frontend/mmucc-app/README.md`](frontend/mmucc-app/README.md) — Angular architecture, route map, component inventory

---

## Reference

- [MMUCC 5th Edition (2017) — NHTSA](https://crashstats.nhtsa.dot.gov/Api/Public/ViewPublication/812433)
