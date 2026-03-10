# crash-service Reference

## Overview

`crash-service` is the core MMUCC data microservice. It manages crash records and all directly related data — vehicles, roadway geometry, and the multi-value child tables defined by the MMUCC 5th Edition specification.

- **Port:** 8082
- **Context path:** `/`
- **Auth:** Stateless JWT (Bearer token, same secret as auth-service — no DB hit per request)
- **Database:** MySQL 8.0 via Flyway-managed schema
- **Swagger UI:** `http://localhost:8082/swagger-ui.html`

---

## Module Structure

```
backend/crash-service/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/gov/nhtsa/mmucc/crash/
    │   │   ├── CrashServiceApplication.java
    │   │   ├── config/
    │   │   │   ├── AppConfig.java           # JwtUtils bean
    │   │   │   ├── JwtProperties.java       # @ConfigurationProperties(prefix="mmucc.jwt")
    │   │   │   ├── OpenApiConfig.java       # SpringDoc bearer auth
    │   │   │   └── SecurityConfig.java      # Role-based HTTP security
    │   │   ├── controller/
    │   │   │   ├── CrashController.java
    │   │   │   ├── VehicleController.java
    │   │   │   └── RoadwayController.java
    │   │   ├── dto/
    │   │   │   ├── ChildCodeDto.java         # Reusable (sequenceNum, code) for multi-value children
    │   │   │   ├── TrafficControlDto.java    # (sequenceNum, tcdTypeCode, tcdInoperativeCode)
    │   │   │   ├── CrashSearchFilter.java    # Query params: dateFrom, dateTo, severity, county, page, size
    │   │   │   ├── CrashRequest.java         # POST/PUT /crashes body
    │   │   │   ├── CrashSummaryResponse.java # Lightweight list item
    │   │   │   ├── CrashDetailResponse.java  # Full aggregate response
    │   │   │   ├── VehicleRequest.java
    │   │   │   ├── VehicleResponse.java
    │   │   │   ├── RoadwayRequest.java
    │   │   │   └── RoadwayResponse.java
    │   │   ├── entity/
    │   │   │   ├── Crash.java
    │   │   │   ├── Vehicle.java
    │   │   │   ├── Roadway.java
    │   │   │   ├── CrashWeatherCondition.java
    │   │   │   ├── CrashSurfaceCondition.java
    │   │   │   ├── CrashContributingRoadway.java
    │   │   │   ├── VehicleTrafficControl.java
    │   │   │   ├── VehicleDamageArea.java
    │   │   │   ├── VehicleSequenceEvent.java
    │   │   │   └── CrashAuditLog.java
    │   │   ├── mapper/
    │   │   │   ├── CrashMapper.java
    │   │   │   ├── VehicleMapper.java
    │   │   │   └── RoadwayMapper.java
    │   │   ├── repository/          # 10 Spring Data JPA repositories
    │   │   ├── security/
    │   │   │   └── JwtAuthenticationFilter.java
    │   │   └── service/
    │   │       ├── AuditLogService.java
    │   │       ├── CrashService.java
    │   │       ├── VehicleService.java
    │   │       └── RoadwayService.java
    │   └── resources/
    │       ├── application.yml
    │       ├── application-local.yml
    │       ├── application-test.yml
    │       └── db/migration/
    │           └── V1__crash_schema.sql
    └── test/
        └── java/gov/nhtsa/mmucc/crash/
            └── CrashIntegrationTest.java
```

---

## API Reference

### Crashes — `/crashes`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/crashes` | Any role | Paged list with optional filters |
| `POST` | `/crashes` | ADMIN, DATA_ENTRY | Create a crash record |
| `GET` | `/crashes/{id}` | Any role | Full detail (crash + vehicles + roadway + all children) |
| `PUT` | `/crashes/{id}` | ADMIN, DATA_ENTRY | Replace all crash scalar fields |
| `DELETE` | `/crashes/{id}` | ADMIN | Delete crash and all children (cascade) |

**Query parameters for `GET /crashes`:**

| Parameter | Type | Description |
|---|---|---|
| `dateFrom` | `LocalDate` | Inclusive start date filter |
| `dateTo` | `LocalDate` | Inclusive end date filter |
| `severity` | `Integer` | Crash severity code filter |
| `county` | `String` | County FIPS code filter |
| `page` | `int` (default 0) | Page index |
| `size` | `int` (default 20, max 100) | Page size |

### Vehicles — `/crashes/{crashId}/vehicles`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/crashes/{crashId}/vehicles` | Any role | All vehicles for a crash, ordered by unit number |
| `POST` | `/crashes/{crashId}/vehicles` | ADMIN, DATA_ENTRY | Add a vehicle |
| `GET` | `/crashes/{crashId}/vehicles/{vehicleId}` | Any role | Single vehicle detail |
| `PUT` | `/crashes/{crashId}/vehicles/{vehicleId}` | ADMIN, DATA_ENTRY | Replace vehicle |
| `DELETE` | `/crashes/{crashId}/vehicles/{vehicleId}` | ADMIN | Delete vehicle and children |

### Roadway — `/crashes/{crashId}/roadway`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/crashes/{crashId}/roadway` | Any role | Roadway detail (404 if not present) |
| `PUT` | `/crashes/{crashId}/roadway` | ADMIN, DATA_ENTRY | Create or replace roadway (upsert) |
| `DELETE` | `/crashes/{crashId}/roadway` | ADMIN | Delete roadway |

---

## Data Model

### MMUCC Coverage

| Section | Elements | Entity |
|---|---|---|
| Crash (C) | C1–C27 scalar fields | `Crash` + 3 child tables |
| Vehicle (V) | V1–V24 scalar fields | `Vehicle` + 3 child tables |
| Roadway (R) | R1–R16 | `Roadway` |

### Multi-Value Child Tables

Each table stores a `(parentId, sequenceNum, code)` triple and its own audit columns:

| Table | Parent | JSON field in request/response |
|---|---|---|
| `CRASH_WEATHER_CONDITION_TBL` | `CRASH_TBL` | `weatherConditions` |
| `CRASH_SURFACE_CONDITION_TBL` | `CRASH_TBL` | `surfaceConditions` |
| `CRASH_CONTRIBUTING_ROADWAY_TBL` | `CRASH_TBL` | `contributingCircumstances` |
| `VEHICLE_TRAFFIC_CONTROL_TBL` | `VEHICLE_TBL` | `trafficControls` |
| `VEHICLE_DAMAGE_AREA_TBL` | `VEHICLE_TBL` | `damageAreas` |
| `VEHICLE_SEQUENCE_EVENT_TBL` | `VEHICLE_TBL` | `sequenceEvents` |

**Replacement semantics:** On every `POST` or `PUT`, existing children are deleted and re-inserted within the same transaction. Passing `null` clears all children; passing an empty list `[]` also clears them.

---

## Security

### Role-Based Access

| Role | GET | POST / PUT | DELETE |
|---|---|---|---|
| `VIEWER` | ✓ | ✗ | ✗ |
| `ANALYST` | ✓ | ✗ | ✗ |
| `DATA_ENTRY` | ✓ | ✓ | ✗ |
| `ADMIN` | ✓ | ✓ | ✓ |

### JWT Validation

The filter (`JwtAuthenticationFilter`) reads the `Authorization: Bearer <token>` header, validates the JWT signature against `MMUCC_JWT_SECRET`, and reconstructs a `UserPrincipal` from the claims. No database lookup occurs per request.

The secret **must match** the secret configured in `auth-service`. Tokens are issued exclusively by auth-service.

---

## Audit Logging

Every write operation (`CREATE`, `UPDATE`, `DELETE`) inserts a row into `CRASH_AUDIT_LOG_TBL` with:
- `CAL_ACTION_CODE` — `CREATE`, `UPDATE`, or `DELETE`
- `CAL_TABLE_NAME` — table affected (e.g., `CRASH_TBL`, `VEHICLE_TBL`)
- `CAL_RECORD_ID` — PK of the affected row
- `CAL_CRASH_ID` — crash context PK
- `CAL_OLD_VALUE` — JSON snapshot before the change (null for CREATE)
- `CAL_NEW_VALUE` — JSON snapshot after the change (null for DELETE)
- `CAL_USERNAME` — actor from JWT claims

`AuditLogService` uses `Propagation.REQUIRES_NEW` so the audit entry is committed even if the outer business transaction rolls back.

---

## Database Migration

Flyway migration `V1__crash_schema.sql` creates:

```
CRASH_TBL
VEHICLE_TBL                    → FK → CRASH_TBL (cascade delete)
ROADWAY_TBL                    → FK → CRASH_TBL (cascade delete, unique on crash_id)
CRASH_WEATHER_CONDITION_TBL    → FK → CRASH_TBL
CRASH_SURFACE_CONDITION_TBL    → FK → CRASH_TBL
CRASH_CONTRIBUTING_ROADWAY_TBL → FK → CRASH_TBL
VEHICLE_TRAFFIC_CONTROL_TBL    → FK → VEHICLE_TBL
VEHICLE_DAMAGE_AREA_TBL        → FK → VEHICLE_TBL
VEHICLE_SEQUENCE_EVENT_TBL     → FK → VEHICLE_TBL
CRASH_AUDIT_LOG_TBL            (append-only, no FK)
```

All statements use `CREATE TABLE IF NOT EXISTS` — safe to run against an existing schema.

---

## Configuration

### Environment Variables

| Variable | Required | Description |
|---|---|---|
| `MMUCC_JWT_SECRET` | Yes | Base64-encoded 256-bit key — must match auth-service |
| `MMUCC_DB_URL` | No | JDBC URL (default: `jdbc:mysql://localhost:3306/mmucc_db?...`) |
| `MMUCC_DB_USER` | Yes | Database username |
| `MMUCC_DB_PASSWORD` | Yes | Database password |
| `MMUCC_CORS_ORIGINS` | No | Allowed CORS origins (default: `http://localhost:4200`) |

### Profiles

| Profile | Purpose |
|---|---|
| *(default)* | Production — requires all env vars |
| `local` | Development — relaxed settings, SQL logging enabled |
| `test` | Testcontainers — datasource URL injected via `@DynamicPropertySource` |

---

## Running Locally

```bash
# From backend/crash-service/
export MMUCC_DB_USER=mmucc_app
export MMUCC_DB_PASSWORD=changeme_local
export MMUCC_JWT_SECRET=bG9jYWxkZXZzZWNyZXRsb2NhbGRldnNlY3JldGxvY2FsZGV2c2VjcmV0bG9jYQ==

mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Health check: `curl http://localhost:8082/actuator/health`

Swagger UI: `http://localhost:8082/swagger-ui.html`

---

## Integration Tests

```bash
# Requires Docker (for Testcontainers)
mvn test -pl crash-service
```

`CrashIntegrationTest` spins up a real MySQL 8.0 container and covers:

- `POST /crashes` — success (DATA_ENTRY), forbidden (VIEWER), unauthorized
- `POST /crashes` with weather conditions — child records persisted
- `GET /crashes/{id}` — found and not-found
- `GET /crashes` — paged list
- `PUT /crashes/{id}` — update + audit log verification
- `DELETE /crashes/{id}` — admin success, DATA_ENTRY forbidden
- `POST /crashes/{id}/vehicles` — vehicle with VIN and unit number
- `GET /crashes/{id}/vehicles` — returns all vehicles
- `PUT /crashes/{id}/roadway` — upsert on first and second call

---

## Dependencies

| Dependency | Purpose |
|---|---|
| `spring-boot-starter-web` | REST controllers |
| `spring-boot-starter-data-jpa` | Repository layer |
| `spring-boot-starter-security` | JWT filter, method security |
| `spring-boot-starter-validation` | Bean Validation on DTOs |
| `flyway-core` | Schema migration |
| `mapstruct` | Entity ↔ DTO mapping |
| `springdoc-openapi-starter-webmvc-ui` | Swagger UI |
| `jjwt-*` | JWT parsing (shared via `common` module) |
| `mysql-connector-j` | JDBC driver (runtime) |
| `testcontainers` | Integration tests against real MySQL |
