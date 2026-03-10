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
This is the core service. Structure it around the MMUCC hierarchy:

```
POST   /crashes                  → create crash shell
PUT    /crashes/{id}             → update crash-level fields
POST   /crashes/{id}/vehicles    → add vehicle
POST   /crashes/{id}/persons     → add person
...etc for each child entity
GET    /crashes/{id}             → full crash with all children
```

Key implementation details:
- **One JPA entity per table**, with the audit columns mapped to a reusable `@Embeddable` base class
- **Service layer populates audit fields** — never let the controller touch `CREATED_BY`, `MODIFIED_BY`, etc.
- **DTOs separate from entities** — use MapStruct to avoid exposing internal structure
- Wrap every write operation in a transaction that also inserts a row into `CRASH_AUDIT_LOG_TBL` (before/after JSON snapshot)
- Use **Spring Data JPA projections** for list/summary views to avoid fetching full object graphs

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
