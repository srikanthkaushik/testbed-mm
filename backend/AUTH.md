# auth-service

Firebase-backed authentication, JWT issuance, and user management for the MMUCC 5th Edition backend.

---

## Architecture

```
Angular (Firebase SDK)
    │  signs in via Firebase Auth
    │  receives Firebase ID Token
    ▼
POST /auth/login  { firebaseIdToken }
    │
    ├─ FirebaseAuthGateway.verifyIdToken(token, checkRevoked=true)
    │       └─ rejects tokens revoked from Firebase Console immediately
    │
    ├─ Look up user in APP_USER_TBL by AUS_FIREBASE_UID
    │       └─ auto-provisions a VIEWER account on first login
    │
    ├─ Issues internal JWT (15 min, HS256)
    ├─ Issues refresh token → SHA-256 hash stored in DB
    │       └─ raw token returned as HttpOnly SameSite=Strict cookie
    │
    └─ Writes LOGIN event to CRASH_AUDIT_LOG_TBL (REQUIRES_NEW tx)

All subsequent API calls → Authorization: Bearer <internal JWT>
    │
    └─ JwtAuthenticationFilter: validates JWT, populates SecurityContext
           └─ no DB lookup on every request — identity lives in JWT claims
```

---

## Module Structure

```
backend/
├── pom.xml                  ← Parent aggregator POM
├── common/                  ← Shared library (JwtUtils, AuditFields, exceptions, DTOs)
└── auth-service/
    ├── pom.xml
    └── src/
        ├── main/
        │   ├── java/gov/nhtsa/mmucc/auth/
        │   │   ├── AuthServiceApplication.java
        │   │   ├── config/
        │   │   │   ├── AppConfig.java           ← @Bean JwtUtils
        │   │   │   ├── FirebaseConfig.java       ← Firebase Admin SDK init (@Profile !test)
        │   │   │   ├── JwtProperties.java        ← @ConfigurationProperties mmucc.jwt
        │   │   │   ├── OpenApiConfig.java        ← SpringDoc / Swagger UI
        │   │   │   └── SecurityConfig.java       ← Filter chain, CORS, permit rules
        │   │   ├── controller/
        │   │   │   ├── AuthController.java       ← /auth/**
        │   │   │   └── AdminUserController.java  ← /admin/users/**
        │   │   ├── dto/                          ← Request/response records
        │   │   ├── entity/
        │   │   │   ├── AppUser.java              ← APP_USER_TBL
        │   │   │   └── CrashAuditLog.java        ← CRASH_AUDIT_LOG_TBL (insert-only)
        │   │   ├── firebase/
        │   │   │   ├── FirebaseAuthGateway.java  ← Interface (mockable in tests)
        │   │   │   ├── FirebaseAuthGatewayImpl.java
        │   │   │   └── FirebaseTokenClaims.java  ← Decoupled DTO from Firebase SDK type
        │   │   ├── mapper/
        │   │   │   └── UserMapper.java           ← MapStruct entity ↔ DTO
        │   │   ├── repository/
        │   │   │   ├── AppUserRepository.java
        │   │   │   └── CrashAuditLogRepository.java
        │   │   ├── security/
        │   │   │   └── JwtAuthenticationFilter.java
        │   │   └── service/
        │   │       ├── AuditLogService.java      ← LOGIN/LOGOUT events
        │   │       ├── AuthService.java           ← login / refresh / logout
        │   │       ├── RoleCode.java              ← ADMIN, DATA_ENTRY, ANALYST, VIEWER
        │   │       └── UserAdminService.java      ← Admin CRUD
        │   └── resources/
        │       ├── application.yml
        │       ├── application-local.yml
        │       ├── application-test.yml
        │       └── db/migration/
        │           └── V1__auth_schema.sql       ← Flyway baseline (APP_USER_TBL + CRASH_AUDIT_LOG_TBL)
        └── test/
            └── java/gov/nhtsa/mmucc/auth/
                ├── AuthLoginIntegrationTest.java ← Testcontainers + MockMvc
                └── config/TestFirebaseConfig.java
```

---

## API Endpoints

| Method | Path | Auth Required | Description |
|---|---|---|---|
| `POST` | `/auth/login` | None | Exchange a Firebase ID token for an internal JWT |
| `POST` | `/auth/refresh` | HttpOnly cookie | Rotate the refresh token and issue a new access token |
| `POST` | `/auth/logout` | Bearer JWT | Invalidate the refresh token and clear the cookie |
| `GET` | `/auth/me` | Bearer JWT | Return the current user's identity |
| `POST` | `/admin/users` | ADMIN | Pre-provision a user account |
| `GET` | `/admin/users` | ADMIN | Paginated user list (optional `?role=` filter) |
| `GET` | `/admin/users/{id}` | ADMIN | Get user by ID |
| `PUT` | `/admin/users/{id}/role` | ADMIN | Update a user's role |
| `PUT` | `/admin/users/{id}/status` | ADMIN | Activate or deactivate an account |

Swagger UI available at `http://localhost:8081/swagger-ui.html` when running locally.

---

## Token Design

### Access Token (JWT)

- Algorithm: HS256
- Lifespan: 15 minutes (configurable via `mmucc.jwt.access-token-expiration-ms`)
- Transport: `Authorization: Bearer <token>` header

Claims:

| Claim | Value |
|---|---|
| `sub` | `AUS_USER_ID` (String) |
| `uid` | Firebase UID (`AUS_FIREBASE_UID`) |
| `uname` | Username |
| `email` | Email address |
| `role` | Role code (`ADMIN`, `DATA_ENTRY`, `ANALYST`, `VIEWER`) |
| `agency` | Agency code (omitted if null) |
| `iss` | `mmucc-auth-service` |
| `jti` | Random UUID (for future token blocklist) |

### Refresh Token

- Lifespan: 7 days (configurable via `mmucc.jwt.refresh-token-expiration-days`)
- Transport: `HttpOnly; Secure; SameSite=Strict; Path=/auth/refresh` cookie
- Storage: SHA-256 hex hash stored in `APP_USER_TBL.AUS_REFRESH_TOKEN_HASH`
- Rotation: single-use — every `/auth/refresh` call invalidates the previous token

The `Path=/auth/refresh` scope means the browser only sends this cookie to the refresh endpoint, limiting its exposure.

---

## Roles

| Role | Description |
|---|---|
| `ADMIN` | Full system administration, user management |
| `DATA_ENTRY` | Create and edit crash records |
| `ANALYST` | Read-only analysis and reporting |
| `VIEWER` | Read-only access to crash records |

New users auto-provisioned on first Firebase login receive the `VIEWER` role. An ADMIN can upgrade their role via `PUT /admin/users/{id}/role`.

---

## Database Schema Changes

auth-service manages its own Flyway migrations in `src/main/resources/db/migration/`.

`V1__auth_schema.sql` creates:
- `APP_USER_TBL` — includes Firebase columns from baseline:
  - `AUS_FIREBASE_UID VARCHAR(128) UNIQUE` — links Firebase identity to local account
  - `AUS_REFRESH_TOKEN_HASH VARCHAR(255)` — hashed refresh token
  - `AUS_REFRESH_TOKEN_EXPIRY DATETIME` — refresh token expiry
  - `AUS_PASSWORD_HASH` is nullable (Firebase manages credentials)
- `CRASH_AUDIT_LOG_TBL` — append-only audit log

If applying Firebase support to an existing deployment that used the original `30_APP_USER_TBL.sql`:

```sql
ALTER TABLE APP_USER_TBL
    MODIFY COLUMN AUS_PASSWORD_HASH VARCHAR(255) NULL,
    ADD COLUMN AUS_FIREBASE_UID        VARCHAR(128) NULL UNIQUE  AFTER AUS_PASSWORD_HASH,
    ADD COLUMN AUS_REFRESH_TOKEN_HASH  VARCHAR(255) NULL         AFTER AUS_FIREBASE_UID,
    ADD COLUMN AUS_REFRESH_TOKEN_EXPIRY DATETIME    NULL         AFTER AUS_REFRESH_TOKEN_HASH;
```

---

## Configuration

All secrets must be supplied via environment variables. Never commit real values.

| Property | Env Var | Description |
|---|---|---|
| `mmucc.jwt.secret` | `MMUCC_JWT_SECRET` | Base64-encoded 256-bit HMAC key. Generate: `openssl rand -base64 32` |
| `spring.datasource.url` | `MMUCC_DB_URL` | MySQL JDBC URL |
| `spring.datasource.username` | `MMUCC_DB_USER` | DB username |
| `spring.datasource.password` | `MMUCC_DB_PASSWORD` | DB password |
| `firebase.service-account-path` | `FIREBASE_SERVICE_ACCOUNT_PATH` | Absolute path to Firebase service account JSON |
| `mmucc.cors.allowed-origins` | `MMUCC_CORS_ORIGINS` | Comma-separated allowed origins (default: `http://localhost:4200`) |

### Running locally

```bash
export MMUCC_DB_USER=mmucc_user
export MMUCC_DB_PASSWORD=changeme
export MMUCC_JWT_SECRET=$(openssl rand -base64 32)
export FIREBASE_SERVICE_ACCOUNT_PATH=$HOME/.mmucc/firebase-service-account.json

mvn -pl common install -q
mvn -pl auth-service spring-boot:run -Dspring-boot.run.profiles=local
```

Service starts on port `8081`.

---

## Testing

Integration tests use Testcontainers (real MySQL) and mock the Firebase gateway:

```bash
mvn -pl common install -q
mvn -pl auth-service test
```

`FirebaseAuthGateway` is replaced with a `@MockBean` in tests. `FirebaseConfig` and `FirebaseAuthGatewayImpl` are excluded via `@Profile("!test")`, so no Firebase credentials are needed to run tests.

Test coverage:
- Successful login → 200, access token, HttpOnly cookie, audit log entry
- Locked account → 403
- Disabled account → 403
- Missing/blank token → 400
- Refresh token rotation → new token issued, old token invalidated

---

## Security Notes

- Firebase token verification uses `checkRevoked=true` — sessions revoked from the Firebase Console are rejected within seconds, not waiting for the 1-hour Firebase token expiry.
- Refresh tokens are stored as SHA-256 hashes only. A stolen database dump cannot replay refresh tokens.
- The `JwtAuthenticationFilter` does not query the database on every request — all identity data is embedded in the JWT. Role changes and account deactivation take up to 15 minutes to propagate naturally; for immediate revocation, use Firebase session revocation which invalidates the next login.
- Audit log writes use `Propagation.REQUIRES_NEW` — LOGIN/LOGOUT entries are committed even if the surrounding transaction rolls back.
