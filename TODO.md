# TODO — Applying Sprint 3 Changes to the Live Database

> **Status as of 2026-03-16: Complete.** V6 and V7 have been applied to `mmucc5`. crash-service is running with all Sprint 3 endpoints active. The steps below are preserved for reference and for applying to any other environment (staging, production).


This document describes every manual step required to bring the **running `mmucc5` MySQL database and crash-service instance** up to date with the Sprint 3 code changes. No application data will be lost. All changes are additive (new columns, new indexes — no drops or renames on existing columns).

---

## Background

Sprint 3 added Person (P1–P27), Fatal Section, Non-Motorist, Large Vehicle, and Vehicle Automation support to crash-service. Three things changed in the codebase that affect the live database:

| What changed | Effect on live DB |
|---|---|
| `V3__fix_column_types.sql` was modified — DROP FK statements were added (with `SET FOREIGN_KEY_CHECKS=0`) so the migration is safe in Testcontainers | Flyway will detect a **checksum mismatch** for V3 on startup and refuse to proceed |
| `V6__person_schema.sql` is a new migration | It has never run on the live DB — Flyway will apply it automatically once the V3 checksum issue is fixed |
| 13 new JPA entities, controllers, and services added | No DB impact — they map to tables that already exist as stubs from the original DDL |

---

## What V6 Does to the Live Database

V6 adds data columns to 13 stub tables that already exist in `mmucc5` but currently contain only PK/FK audit columns. All new columns are `NULL`-able (or have defaults), so existing rows are unaffected.

V6 is **idempotent** — every `ADD COLUMN` and `CREATE INDEX` is wrapped in a stored-procedure guard that checks `information_schema` first, so it is safe to apply regardless of whether the columns were already created by the original DDL scripts.

| Table | Columns Added |
|---|---|
| `PERSON_TBL` | 45 data columns (P1–P27: name, DOB, sex, injury status, restraint, DL info, BAC, etc.) + 2 indexes |
| `PERSON_AIRBAG_TBL` | `PAB_SEQUENCE_NUM`, `PAB_AIRBAG_CODE` |
| `PERSON_DRIVER_ACTION_TBL` | `PDA_SEQUENCE_NUM`, `PDA_ACTION_CODE` |
| `PERSON_DL_RESTRICTION_TBL` | `PDR_SEQUENCE_NUM`, `PDR_RESTRICTION_CODE` |
| `PERSON_DRUG_TEST_RESULT_TBL` | `DTR_SEQUENCE_NUM`, `DTR_RESULT_CODE` |
| `FATAL_SECTION_TBL` | 5 columns (F1–F3: avoidance maneuver, alcohol/drug test) |
| `NON_MOTORIST_TBL` | 7 columns (NM1–NM6: action, origin/destination, location, contact point) |
| `NON_MOTORIST_SAFETY_EQUIPMENT_TBL` | `NMS_SEQUENCE_NUM`, `NMS_EQUIPMENT_CODE` |
| `LARGE_VEHICLE_TBL` | 38 columns (LV1–LV11: trailers, carrier info, cargo, HazMat, axles) |
| `LV_SPECIAL_SIZING_TBL` | `LVS_SEQUENCE_NUM`, `LVS_SIZING_CODE` |
| `VEHICLE_AUTOMATION_TBL` | `VAT_AUTOMATION_PRESENT_CODE` |
| `VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL` | `VAI_SEQUENCE_NUM`, `VAI_AUTOMATION_LEVEL_CODE` |
| `VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL` | `VAE_SEQUENCE_NUM`, `VAE_AUTOMATION_LEVEL_CODE` |

---

## Step-by-Step Instructions

### Step 1 — Stop crash-service

Stop the running crash-service process before making any changes. This prevents Flyway from running on startup and hitting the checksum error mid-operation.

---

### Step 2 — Fix the V3 Flyway Checksum Mismatch

The `V3__fix_column_types.sql` file was modified after it was already applied to the live DB. Flyway stores a checksum of every applied migration and will refuse to start if the file no longer matches.

The fix is already applied in `application-local.yml` — `validate-on-migrate: false` is set, which tells Flyway to skip checksum validation and proceed directly to applying any pending migrations (V6). This is safe because V3's DDL has already run successfully and is not being re-executed.

No manual action needed for this step — simply start crash-service in Step 3.

**Verify it worked:**

```sql
SELECT version, description, checksum, success
FROM mmucc5.flyway_crash_schema_history
ORDER BY installed_rank;
```

You should see rows for V1 (baseline), V3, V4, V5 — all with `success = 1`. V6 will not appear yet.

---

### Step 3 — Start crash-service

Start crash-service normally with the `local` profile. On startup, Flyway will:

1. Validate V1 (baseline) — ✓ no change
2. Validate V3 — ✓ checksum now matches (repaired in Step 2)
3. Validate V4 — ✓ no change
4. Validate V5 — ✓ no change
5. **Apply V6** — adds all Person/Fatal/NonMotorist/LargeVehicle/Automation columns
6. Hibernate validates the schema against all JPA entities — ✓ all columns now present

```bash
cd C:/DEVL/mmucc-develop/backend/crash-service
mvn spring-boot:run -Dspring-boot.run.profiles=local
```

Watch the startup log for:

```
Flyway Community Edition ... by Redgate
...
Current version of schema `mmucc5`: 5
Migrating schema `mmucc5` to version "6 - person schema"
Successfully applied 1 migration to schema `mmucc5` (execution time ...).
...
HHH000490: Using JPA persistence provider: org.hibernate.jpa.HibernatePersistenceProvider
Started CrashServiceApplication in ...
```

If you see `Started CrashServiceApplication` without errors, the migration is complete.

---

### Step 4 — Verify the New Columns Exist

Connect to MySQL and run a quick spot-check:

```sql
-- Verify Person columns were added
SELECT COUNT(*)
FROM information_schema.COLUMNS
WHERE table_schema = 'mmucc5'
  AND table_name   = 'PERSON_TBL'
  AND column_name  = 'PRS_INJURY_STATUS_CODE';
-- Expected: 1

-- Verify all 13 tables now have their data columns
SELECT table_name, COUNT(*) AS column_count
FROM information_schema.COLUMNS
WHERE table_schema = 'mmucc5'
  AND table_name IN (
    'PERSON_TBL', 'PERSON_AIRBAG_TBL', 'PERSON_DRIVER_ACTION_TBL',
    'PERSON_DL_RESTRICTION_TBL', 'PERSON_DRUG_TEST_RESULT_TBL',
    'FATAL_SECTION_TBL', 'NON_MOTORIST_TBL', 'NON_MOTORIST_SAFETY_EQUIPMENT_TBL',
    'LARGE_VEHICLE_TBL', 'LV_SPECIAL_SIZING_TBL',
    'VEHICLE_AUTOMATION_TBL', 'VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL',
    'VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL'
  )
GROUP BY table_name
ORDER BY table_name;

-- Verify Flyway recorded V6 as applied
SELECT version, description, installed_on, success
FROM mmucc5.flyway_crash_schema_history
ORDER BY installed_rank;
-- Should show V1 through V6, all success = 1
```

---

### Step 5 — Re-enable Flyway Validation

Once V6 has applied successfully (confirmed in Step 4), re-enable checksum validation so Flyway resumes its normal protective behaviour. In `backend/crash-service/src/main/resources/application-local.yml`, remove or comment out the `validate-on-migrate: false` line:

```yaml
  flyway:
    baseline-on-migrate: true
    # validate-on-migrate: false   ← remove this line
```

Restart crash-service once more. The startup log should show:

```
Successfully validated 5 migrations (execution time ...)
Current version of schema `mmucc5`: 6
```

---

### Step 6 — Smoke-Test the New Endpoints

With both services running (auth-service on :8081, crash-service on :8082), verify the new Person endpoints work end-to-end via Swagger UI or curl.

**Create a person under an existing vehicle:**

```bash
curl -s -X POST http://localhost:8082/crashes/{crashId}/vehicles/{vehicleId}/persons \
  -H "Authorization: Bearer <your-jwt>" \
  -H "Content-Type: application/json" \
  -d '{
    "personNum": 1,
    "personTypeCode": 1,
    "injuryStatusCode": 4,
    "sexCode": 1,
    "ageYears": 35
  }' | jq .
```

Expected: `HTTP 201` with the new person's ID in the response.

**Swagger UI** (all new endpoints are documented there):
```
http://localhost:8082/swagger-ui.html
```

New endpoint groups (also visible in Swagger UI):
- `POST/GET/PUT/DELETE /crashes/{crashId}/vehicles/{vehicleId}/persons`
- `PUT/GET/DELETE /crashes/{crashId}/vehicles/{vehicleId}/persons/{personId}/fatal`
- `PUT/GET/DELETE /crashes/{crashId}/vehicles/{vehicleId}/persons/{personId}/non-motorist`
- `PUT/GET/DELETE /crashes/{crashId}/vehicles/{vehicleId}/large-vehicle`
- `PUT/GET/DELETE /crashes/{crashId}/vehicles/{vehicleId}/automation`

---

## Rollback Plan

These changes are additive only. If something goes wrong:

1. **Stop crash-service**
2. Drop the newly added columns manually (or restore from a DB backup)
3. Delete the V6 row from `flyway_crash_schema_history`:
   ```sql
   DELETE FROM mmucc5.flyway_crash_schema_history WHERE version = '6';
   ```
4. Check out the previous version of V3 from git to restore the pre-Sprint-3 file, then repair again:
   ```bash
   git show HEAD~1:backend/crash-service/src/main/resources/db/migration/V3__fix_column_types.sql \
     > backend/crash-service/src/main/resources/db/migration/V3__fix_column_types.sql
   mvn flyway:repair -pl crash-service ...
   ```
5. Check out the previous crash-service JAR / source and restart

> **Recommendation:** Take a MySQL dump before running Step 2 if this is a database with any real data you cannot afford to lose:
> ```bash
> mysqldump -u mmucc_user -p mmucc5 > mmucc5_backup_before_sprint3.sql
> ```
