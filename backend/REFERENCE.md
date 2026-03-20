# reference-service

Read-only lookup API serving all MMUCC 5th Edition coded-value reference data from the seven `REF_*` tables in MySQL.

- **Port:** 8083
- **Context path:** `/`
- **Auth:** None — all endpoints are public (reference data is not sensitive)
- **Database:** MySQL 8.0 — read-only access to `REF_*` tables (no Flyway, no DDL)
- **Swagger UI:** `http://localhost:8083/swagger-ui.html`

---

## Purpose

The MMUCC specification defines hundreds of coded fields where integer values map to human-readable descriptions. Historically these maps were hardcoded in the Angular frontend (`mmucc-lookup.ts`). The reference-service centralises this data in the database so:

- Coded values can be updated without redeploying the frontend.
- Some reference tables carry business-logic flags (e.g. `requiresFatalSection`, `isNonMotorist`) that the frontend uses to conditionally show or hide form sections — these are now authoritative from the DB rather than hardcoded arrays.
- A future reference-service client (report-service, API gateway, etc.) can consume the same data without duplicating the maps.

---

## Architecture

```
Angular (ReferenceService)
    │  GET /lookups   ← single bulk call at app startup (APP_INITIALIZER)
    ▼
reference-service (port 8083)
    │
    ├─ LookupService.init() → @PostConstruct
    │       └─ queries all 7 REF_* tables once at startup
    │               └─ builds in-memory Map<type, List<LookupEntryDto>>
    │
    ├─ GET /lookups         → Map (all 7 types)
    └─ GET /lookups/{type}  → List (one type)

Angular signals updated:
    crashTypes, harmfulEvents, weatherConditions, surfaceConditions,
    personTypes, injuryStatuses, bodyTypes
```

The in-memory cache is populated once on startup. Updating coded values in the database requires a service restart to take effect — this is acceptable since reference data changes very rarely.

---

## Module Structure

```
backend/reference-service/
├── pom.xml
└── src/main/
    ├── java/gov/nhtsa/mmucc/reference/
    │   ├── ReferenceServiceApplication.java
    │   ├── config/
    │   │   ├── WebConfig.java       ← CORS configuration (GET + OPTIONS only)
    │   │   └── OpenApiConfig.java   ← SpringDoc / Swagger UI
    │   ├── controller/
    │   │   └── LookupController.java  ← GET /lookups and GET /lookups/{type}
    │   ├── dto/
    │   │   └── LookupEntryDto.java    ← code, description + nullable type-specific fields
    │   ├── entity/
    │   │   ├── RefCrashType.java
    │   │   ├── RefHarmfulEvent.java
    │   │   ├── RefWeatherCondition.java
    │   │   ├── RefSurfaceCondition.java
    │   │   ├── RefPersonType.java
    │   │   ├── RefInjuryStatus.java
    │   │   └── RefBodyType.java
    │   ├── repository/
    │   │   └── Ref*Repository.java    ← 7 Spring Data repositories (findAllByOrderByCodeAsc)
    │   └── service/
    │       └── LookupService.java     ← @PostConstruct cache init
    └── resources/
        ├── application.yml
        └── application-local.yml
```

---

## API Reference

### `GET /lookups`

Returns all 7 lookup types in a single JSON object. Use this at application startup to pre-load the full reference dataset in one network round-trip.

**Response shape:**

```json
{
  "crash-types":        [ { "code": 1, "description": "Single Vehicle" }, ... ],
  "harmful-events":     [ { "code": 1, "description": "Overturn/Rollover", "category": "NON_COLLISION_HARMFUL" }, ... ],
  "weather-conditions": [ { "code": 1, "description": "Clear" }, ... ],
  "surface-conditions": [ { "code": 1, "description": "Dry" }, ... ],
  "person-types":       [ { "code": 1, "description": "Driver", "isNonMotorist": false }, ... ],
  "injury-statuses":    [ { "code": 1, "description": "(K) Fatal Injury", "kabcoLetter": "K", "requiresFatalSection": true }, ... ],
  "body-types":         [ { "code": 1, "description": "All-Terrain Vehicle/ATC", "requiresLvSection": false }, ... ]
}
```

`Cache-Control: public, max-age=86400` is set on the response — browsers and proxies cache for 24 hours.

---

### `GET /lookups/{type}`

Returns the entry list for a single named type.

| `{type}` value     | Source table                  |
|--------------------|-------------------------------|
| `crash-types`      | `REF_CRASH_TYPE_TBL`          |
| `harmful-events`   | `REF_HARMFUL_EVENT_TBL`       |
| `weather-conditions` | `REF_WEATHER_CONDITION_TBL` |
| `surface-conditions` | `REF_SURFACE_CONDITION_TBL` |
| `person-types`     | `REF_PERSON_TYPE_TBL`         |
| `injury-statuses`  | `REF_INJURY_STATUS_TBL`       |
| `body-types`       | `REF_BODY_TYPE_TBL`           |

**404** is returned for any unknown type name, with the list of valid types in the error message.

---

## DTO Reference — `LookupEntryDto`

All responses use the same DTO. Fields that do not apply to a given type are omitted from the JSON (`@JsonInclude(NON_NULL)`).

| Field | Type | Present for |
|---|---|---|
| `code` | `int` | All types |
| `description` | `String` | All types |
| `category` | `String` | `harmful-events` — values: `NON_HARMFUL`, `NON_COLLISION_HARMFUL`, `COLLISION_PERSON_MV`, `COLLISION_FIXED` |
| `kabcoLetter` | `String` | `injury-statuses` — values: `K`, `A`, `B`, `C`, `O` |
| `isNonMotorist` | `Boolean` | `person-types` — `true` means the Non-Motorist section (NM1–NM6) must be completed |
| `requiresFatalSection` | `Boolean` | `injury-statuses` — `true` for code `1` (Fatal); triggers the Fatal Section (F1–F3) |
| `requiresLvSection` | `Boolean` | `body-types` — `true` for large/commercial vehicle body types; triggers the Large Vehicle section (LV1–LV11) |

---

## Reference Tables

The seven `REF_*` tables are created by the MySQL DDL scripts in `database/mysql/` (files `01_` through `07_`). The reference-service connects to the same `mmucc5` database as crash-service and auth-service but only reads from these tables.

| Table | Acronym | MMUCC Element | Rows |
|---|---|---|---|
| `REF_CRASH_TYPE_TBL` | RCT | C2 SF1 — Crash Type | 7 |
| `REF_HARMFUL_EVENT_TBL` | RHE | C7, V20, V21 — Harmful/Sequence Events | 50+ |
| `REF_WEATHER_CONDITION_TBL` | RWC | C11 — Weather Conditions | 10 |
| `REF_SURFACE_CONDITION_TBL` | RSC | C13 — Roadway Surface Condition | 9 |
| `REF_PERSON_TYPE_TBL` | RPT | P4 SF1 — Person Type | 12 |
| `REF_INJURY_STATUS_TBL` | RIS | P5 — Injury Status (KABCO) | 5 |
| `REF_BODY_TYPE_TBL` | RBT | V8 SF1 — Motor Vehicle Body Type | 20+ |

**No Flyway** — the reference-service does not manage schema migrations. `spring.jpa.hibernate.ddl-auto=none` prevents Hibernate from touching the schema. If a REF table is missing, the `@PostConstruct` will fail at startup with a clear JPA error.

---

## Frontend Integration

### Angular `ReferenceService`

Located at `src/app/core/services/reference.service.ts`. Injected app-wide (`providedIn: 'root'`).

**Startup flow:**

```
app.config.ts → APP_INITIALIZER → ReferenceService.loadAll()
                                        │
                                  GET /lookups (single HTTP call)
                                        │
                            ┌───────────┴──────────────┐
                       success                        error
                            │                            │
                 signals populated             console.warn logged
                 (7 lookup signals)            signals stay empty []
                                              (static mmucc-lookup.ts
                                               maps remain in use)
```

Failure is **non-fatal** — if the reference-service is not running, the Angular app continues to function using the hardcoded static maps in `mmucc-lookup.ts`.

**Available signals:**

| Signal | Type | Content |
|---|---|---|
| `crashTypes` | `signal<LookupEntry[]>` | All crash type coded values |
| `harmfulEvents` | `signal<LookupEntry[]>` | All harmful/sequence event codes + categories |
| `weatherConditions` | `signal<LookupEntry[]>` | Weather condition codes |
| `surfaceConditions` | `signal<LookupEntry[]>` | Surface condition codes |
| `personTypes` | `signal<LookupEntry[]>` | Person type codes + `isNonMotorist` flag |
| `injuryStatuses` | `signal<LookupEntry[]>` | Injury status codes + `kabcoLetter` + `requiresFatalSection` |
| `bodyTypes` | `signal<LookupEntry[]>` | Body type codes + `requiresLvSection` flag |

**Helper methods:**

```typescript
// Display label for a coded value
referenceService.label(referenceService.personTypes(), 1)
// → "Driver"

// Business-logic flag helpers (used in PersonFormComponent)
referenceService.isNonMotoristType(5)       // → true  (Pedestrian)
referenceService.requiresFatalSection(1)    // → true  (Fatal Injury)
referenceService.requiresLvSection(22)      // → true  (Semi-Trailer)
```

### Dev Proxy

`proxy.conf.json` forwards `/lookups/**` to `http://localhost:8083`. No CORS configuration is needed in development.

```json
"/lookups": {
  "target": "http://localhost:8083",
  "secure": false,
  "changeOrigin": true
}
```

---

## Configuration

### Environment Variables

| Variable | Required | Description |
|---|---|---|
| `MMUCC_DB_URL` | No | MySQL JDBC URL (default: `jdbc:mysql://localhost:3306/mmucc_db?...`) |
| `MMUCC_DB_USER` | Yes | Database username |
| `MMUCC_DB_PASSWORD` | Yes | Database password |
| `MMUCC_CORS_ORIGINS` | No | Allowed CORS origins (default: `http://localhost:4200`) |

No JWT secret is required — this service issues no tokens and validates none.

### Profiles

| Profile | Purpose |
|---|---|
| *(default)* | Production — requires `MMUCC_DB_USER` and `MMUCC_DB_PASSWORD` env vars |
| `local` | Development — uses hardcoded local DB credentials, SQL logging enabled |

---

## Running Locally

```bash
export MMUCC_DB_USER=mmucc_user
export MMUCC_DB_PASSWORD=changeme_local

# From backend/ (builds common + reference-service)
mvn spring-boot:run -pl reference-service -am -Dspring-boot.run.profiles=local
```

Health check:

```bash
curl http://localhost:8083/actuator/health
```

Verify the cache loaded correctly:

```bash
# All types in one call
curl http://localhost:8083/lookups | jq 'keys'

# Single type
curl http://localhost:8083/lookups/injury-statuses | jq .
```

Swagger UI: `http://localhost:8083/swagger-ui.html`

---

## Dependencies

| Dependency | Purpose |
|---|---|
| `spring-boot-starter-web` | REST controllers |
| `spring-boot-starter-data-jpa` | Repository layer, entity mapping |
| `spring-boot-starter-actuator` | `/actuator/health` endpoint |
| `springdoc-openapi-starter-webmvc-ui` | Swagger UI |
| `mysql-connector-j` | JDBC driver |
| `lombok` | `@Getter` on read-only entities |

No Spring Security, no Flyway, no MapStruct, no JWT — intentionally minimal.
