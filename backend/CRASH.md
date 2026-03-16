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
    │   │   │   ├── RoadwayController.java
    │   │   │   ├── PersonController.java        # Persons + Fatal + Non-Motorist sub-resources
    │   │   │   ├── LargeVehicleController.java  # Large Vehicle / HazMat section
    │   │   │   └── VehicleAutomationController.java
    │   │   ├── dto/
    │   │   │   ├── ChildCodeDto.java         # Reusable (sequenceNum, code) for multi-value children
    │   │   │   ├── TrafficControlDto.java    # (sequenceNum, tcdTypeCode, tcdInoperativeCode)
    │   │   │   ├── PersonDrugTestDto.java    # (sequenceNum, resultCode)
    │   │   │   ├── CrashSearchFilter.java    # Query params: dateFrom, dateTo, severity, county, page, size
    │   │   │   ├── CrashRequest.java / CrashSummaryResponse.java / CrashDetailResponse.java
    │   │   │   ├── VehicleRequest.java / VehicleResponse.java
    │   │   │   ├── RoadwayRequest.java / RoadwayResponse.java
    │   │   │   ├── PersonRequest.java / PersonResponse.java
    │   │   │   ├── FatalSectionRequest.java / FatalSectionResponse.java
    │   │   │   ├── NonMotoristRequest.java / NonMotoristResponse.java
    │   │   │   ├── LargeVehicleRequest.java / LargeVehicleResponse.java
    │   │   │   └── VehicleAutomationRequest.java / VehicleAutomationResponse.java
    │   │   ├── entity/
    │   │   │   ├── Crash.java / Vehicle.java / Roadway.java
    │   │   │   ├── CrashWeatherCondition.java / CrashSurfaceCondition.java / CrashContributingRoadway.java
    │   │   │   ├── VehicleTrafficControl.java / VehicleDamageArea.java / VehicleSequenceEvent.java
    │   │   │   ├── Person.java
    │   │   │   ├── PersonAirbag.java / PersonDriverAction.java
    │   │   │   ├── PersonDlRestriction.java / PersonDrugTestResult.java
    │   │   │   ├── FatalSection.java
    │   │   │   ├── NonMotorist.java / NonMotoristSafetyEquipment.java
    │   │   │   ├── LargeVehicle.java / LvSpecialSizing.java
    │   │   │   ├── VehicleAutomation.java
    │   │   │   ├── VehicleAutomationLevelInVehicle.java / VehicleAutomationLevelEngaged.java
    │   │   │   └── CrashAuditLog.java
    │   │   ├── mapper/
    │   │   │   ├── CrashMapper.java / VehicleMapper.java / RoadwayMapper.java
    │   │   │   ├── PersonMapper.java / FatalSectionMapper.java
    │   │   │   ├── NonMotoristMapper.java / LargeVehicleMapper.java
    │   │   │   └── VehicleAutomationMapper.java
    │   │   ├── repository/          # 23 Spring Data JPA repositories
    │   │   ├── security/
    │   │   │   └── JwtAuthenticationFilter.java
    │   │   └── service/
    │   │       ├── AuditLogService.java
    │   │       ├── CrashService.java / VehicleService.java / RoadwayService.java
    │   │       ├── PersonService.java       # Person CRUD + Fatal + Non-Motorist sub-resources
    │   │       ├── LargeVehicleService.java
    │   │       └── VehicleAutomationService.java
    │   └── resources/
    │       ├── application.yml
    │       ├── application-local.yml
    │       ├── application-test.yml
    │       └── db/migration/
    │           ├── V1__crash_schema.sql   # All 22 tables (stubs for person/conditional tables)
    │           ├── V3__fix_column_types.sql  # INT UNSIGNED → BIGINT for all PK/FK columns
    │           ├── V4__fix_data_column_types.sql  # TINYINT/SMALLINT UNSIGNED → INT (crash/vehicle/roadway)
    │           ├── V5__fix_char_column_types.sql  # CHAR(1) → VARCHAR(1) for RWY_GRADE_DIRECTION
    │           ├── V6__person_schema.sql   # Add P1-P27 + conditional section data columns (idempotent)
    │           └── V7__fix_person_column_types.sql  # TINYINT/SMALLINT UNSIGNED → INT (person tables)
    └── test/
        └── java/gov/nhtsa/mmucc/crash/
            ├── CrashIntegrationTest.java   # 14 tests: crash, vehicle, roadway CRUD
            └── PersonIntegrationTest.java  # 14 tests: person, fatal, non-motorist, large vehicle, automation
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

### Persons — `/crashes/{crashId}/vehicles/{vehicleId}/persons`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `.../persons` | Any role | All persons for a vehicle |
| `POST` | `.../persons` | ADMIN, DATA_ENTRY | Add a person |
| `GET` | `.../persons/{personId}` | Any role | Single person detail |
| `PUT` | `.../persons/{personId}` | ADMIN, DATA_ENTRY | Replace person |
| `DELETE` | `.../persons/{personId}` | ADMIN | Delete person and all children |
| `GET` | `.../persons/{personId}/fatal` | Any role | Fatal section (404 if not present) |
| `PUT` | `.../persons/{personId}/fatal` | ADMIN, DATA_ENTRY | Create or replace fatal section (upsert) |
| `DELETE` | `.../persons/{personId}/fatal` | ADMIN | Delete fatal section |
| `GET` | `.../persons/{personId}/non-motorist` | Any role | Non-motorist section (404 if not present) |
| `PUT` | `.../persons/{personId}/non-motorist` | ADMIN, DATA_ENTRY | Create or replace non-motorist section (upsert) |
| `DELETE` | `.../persons/{personId}/non-motorist` | ADMIN | Delete non-motorist section |

### Large Vehicle — `/crashes/{crashId}/vehicles/{vehicleId}/large-vehicle`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `.../large-vehicle` | Any role | Large vehicle / HazMat detail (404 if not present) |
| `PUT` | `.../large-vehicle` | ADMIN, DATA_ENTRY | Create or replace large vehicle section (upsert) |
| `DELETE` | `.../large-vehicle` | ADMIN | Delete large vehicle section |

### Vehicle Automation — `/crashes/{crashId}/vehicles/{vehicleId}/automation`

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `.../automation` | Any role | Automation detail (404 if not present) |
| `PUT` | `.../automation` | ADMIN, DATA_ENTRY | Create or replace automation section (upsert) |
| `DELETE` | `.../automation` | ADMIN | Delete automation section |

---

## Data Model

### MMUCC Coverage

| Section | Elements | Entity |
|---|---|---|
| Crash (C) | C1–C27 | `Crash` + 3 child tables |
| Vehicle (V) | V1–V24 | `Vehicle` + 3 child tables |
| Roadway (R) | R1–R16 | `Roadway` |
| Person (P) | P1–P27 | `Person` + 4 child tables |
| Fatal (F) | F1–F3 | `FatalSection` (1:1 with Person) |
| Non-Motorist (NM) | NM1–NM6 | `NonMotorist` + `NonMotoristSafetyEquipment` |
| Large Vehicle / HazMat (LV) | LV1–LV11 | `LargeVehicle` + `LvSpecialSizing` |
| Dynamic / Automation (DV) | DV1 | `VehicleAutomation` + 2 level child tables |

### Multi-Value Child Tables

Each table stores a `(parentId, sequenceNum, code)` triple and its own audit columns:

| Table | Parent | JSON field |
|---|---|---|
| `CRASH_WEATHER_CONDITION_TBL` | `CRASH_TBL` | `weatherConditions` |
| `CRASH_SURFACE_CONDITION_TBL` | `CRASH_TBL` | `surfaceConditions` |
| `CRASH_CONTRIBUTING_ROADWAY_TBL` | `CRASH_TBL` | `contributingCircumstances` |
| `VEHICLE_TRAFFIC_CONTROL_TBL` | `VEHICLE_TBL` | `trafficControls` |
| `VEHICLE_DAMAGE_AREA_TBL` | `VEHICLE_TBL` | `damageAreas` |
| `VEHICLE_SEQUENCE_EVENT_TBL` | `VEHICLE_TBL` | `sequenceEvents` |
| `PERSON_AIRBAG_TBL` | `PERSON_TBL` | `airbags` |
| `PERSON_DRIVER_ACTION_TBL` | `PERSON_TBL` | `driverActions` |
| `PERSON_DL_RESTRICTION_TBL` | `PERSON_TBL` | `dlRestrictions` |
| `PERSON_DRUG_TEST_RESULT_TBL` | `PERSON_TBL` | `drugTestResults` |
| `NON_MOTORIST_SAFETY_EQUIPMENT_TBL` | `NON_MOTORIST_TBL` | `safetyEquipment` |
| `LV_SPECIAL_SIZING_TBL` | `LARGE_VEHICLE_TBL` | `specialSizing` |
| `VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL` | `VEHICLE_AUTOMATION_TBL` | `levelsInVehicle` |
| `VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL` | `VEHICLE_AUTOMATION_TBL` | `levelsEngaged` |

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

Flyway manages the schema under history table `flyway_crash_schema_history`:

| Version | Description |
|---|---|
| V1 | All 22 MMUCC tables — full DDL for crash/vehicle/roadway tables; `CREATE TABLE IF NOT EXISTS` stubs for person/conditional section tables |
| V3 | Convert all PK/FK columns from `INT UNSIGNED` → `BIGINT` across all 22 tables (live DB fix) |
| V4 | Convert `TINYINT`/`SMALLINT UNSIGNED` data columns → `INT` for crash, vehicle, roadway tables |
| V5 | Convert `RWY_GRADE_DIRECTION` from `CHAR(1)` → `VARCHAR(1)` |
| V6 | Add P1–P27, F1–F3, NM1–NM6, LV1–LV11, DV1 data columns to the stub tables (idempotent via stored-procedure guard) |
| V7 | Convert `TINYINT`/`SMALLINT UNSIGNED`/`YEAR` data columns → `INT` for all Sprint 3 tables |

All V1 `CREATE TABLE` statements use `IF NOT EXISTS` — safe to run against an existing schema. V6 uses information_schema guards so it is safe whether columns already exist or not.

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
