# Backend Development Approach

## Recommended Architecture

### Service Decomposition

Break the backend into 4–5 focused services that mirror the natural boundaries in the MMUCC data model:

| Service | Responsibility |
|---|---|
| **auth-service** | Login, JWT issuance/validation, user management, password reset |
| **crash-service** | Full CRUD for crash records and all child tables (vehicles, persons, roadway, etc.) |
| **reference-service** | Serves lookup/reference data (read-only; cached aggressively) |
| **report-service** | Read-only queries, aggregations, data exports (CSV/Excel) |
| **api-gateway** | Single entry point — routing, JWT verification, rate limiting |

Start with `auth-service` and `crash-service` — everything else depends on them.

---

## Development Order

### 1. Project Scaffolding
- Maven multi-module parent POM with a `common` module for shared entities, DTOs, exceptions, and audit utilities
- One Spring Boot module per service
- Shared `common` library published to local Maven repo or included as a module dependency

### 2. Database Migration Tooling
- Integrate **Flyway** or **Liquibase** into each service — the SQL files already in `database/mysql/` become the initial migration scripts (V1)
- This gives repeatable, versioned schema management from day one

### 3. auth-service
- Firebase Authentication integration — verifies Firebase ID tokens, issues internal JWTs
- Role-based access: `ADMIN`, `DATA_ENTRY`, `ANALYST`, `VIEWER`
- Refresh token rotation with HttpOnly cookie transport
- Writes login/logout events to `CRASH_AUDIT_LOG_TBL`

See [AUTH.md](AUTH.md) for full implementation details, API reference, token design, and setup instructions.

### 4. crash-service
The core MMUCC data service running on port **8082**. Covers crash records (C1–C27), vehicles (V1–V24), roadway (R1–R16), and all associated multi-value child tables.

**API surface:**

```
GET    /crashes                          → paged list (filters: dateFrom, dateTo, severity, county)
POST   /crashes                          → create crash (ADMIN, DATA_ENTRY)
GET    /crashes/{id}                     → full detail — crash + all children
PUT    /crashes/{id}                     → replace crash (ADMIN, DATA_ENTRY)
DELETE /crashes/{id}                     → delete + cascade (ADMIN)

GET    /crashes/{id}/vehicles            → list vehicles for a crash
POST   /crashes/{id}/vehicles            → add vehicle (ADMIN, DATA_ENTRY)
GET    /crashes/{id}/vehicles/{vid}      → single vehicle detail
PUT    /crashes/{id}/vehicles/{vid}      → replace vehicle (ADMIN, DATA_ENTRY)
DELETE /crashes/{id}/vehicles/{vid}      → delete vehicle (ADMIN)

GET    /crashes/{id}/roadway             → roadway detail (1:1 with crash)
PUT    /crashes/{id}/roadway             → create or replace roadway (ADMIN, DATA_ENTRY)
DELETE /crashes/{id}/roadway             → delete roadway (ADMIN)
```

**Key implementation details:**
- **One JPA entity per table** with audit columns mapped via `@Embeddable AuditFields` and table-specific `@AttributeOverrides`
- **Service layer populates audit fields** — never the controller; explicit actor identity on every write
- **DTOs separate from entities** — MapStruct mappers for Crash, Vehicle, Roadway; `@MappingTarget` for PUT (in-place update)
- **Multi-value child tables** (weather conditions, surface conditions, contributing roadway, traffic controls, damage areas, sequence events) managed with delete-then-insert within the same transaction
- **Roadway upsert** — `PUT /crashes/{id}/roadway` creates on first call, replaces on subsequent calls (no separate POST)
- **`AuditLogService` with `Propagation.REQUIRES_NEW`** — audit entries committed even if the outer transaction rolls back
- **No N+1 queries** — `buildDetailResponse` fetches all children via explicit repository calls, not JPA `@OneToMany`
- **Flyway migration** (`V1__crash_schema.sql`) creates 9 tables with `CREATE TABLE IF NOT EXISTS`
- **JWT filter** shares the same secret as auth-service; no DB hit per request — identity reconstructed from JWT claims

See [CRASH.md](CRASH.md) for full implementation reference, module structure, API details, and local run instructions.

### 5. reference-service
- Simple read-only service over the `REF_*` tables (MySQL) or `LOOKUP_CODE_VALUES_TBL` (Oracle)
- Cache responses with Spring Cache + Caffeine — reference data changes very rarely
- `crash-service` calls this at startup or on-demand to validate coded values

### 6. report-service
- Read-only replica or same DB with read-only credentials
- Query endpoints with filtering (date range, county, severity, etc.)
- CSV/Excel export via Apache POI

---

## Key Technical Decisions

| Decision | Recommendation |
|---|---|
| **JWT storage** | Short-lived access token (15 min) + refresh token stored server-side in DB or Redis |
| **Inter-service communication** | REST + Feign clients for synchronous calls; avoid messaging queues until needed |
| **API documentation** | SpringDoc OpenAPI (Swagger UI) on every service from day one |
| **Error handling** | Global `@RestControllerAdvice` in `common` module — consistent error response shape across all services |
| **Validation** | Jakarta Bean Validation on DTOs; custom validators for MMUCC business rules (e.g., fatal injury requires fatal section) |
| **DB dual-support** | Abstract the Oracle dependency — keep MySQL as primary; Oracle support via a separate Spring profile and data source config |
| **Testing** | Testcontainers for integration tests against a real MySQL instance; no mocking the DB layer |

---

## Sprint Plan

| Sprint | Scope |
|---|---|
| **Sprint 1** | auth-service — login, JWT, user CRUD, roles |
| **Sprint 2** | crash-service — crash + vehicle creation and retrieval |
| **Sprint 3** | crash-service — person, roadway, all child tables |
| **Sprint 4** | Audit logging, MMUCC validation rules, reference-service |
| **Sprint 5** | report-service, CSV/Excel export |

This delivers a working end-to-end flow (create crash → add vehicle → add person) by Sprint 3, which is the earliest point where Angular development can meaningfully begin in parallel.
