-- =============================================================================
-- Migration  : V2 – Align mmucc5 schema with auth-service entities
-- Service    : auth-service
-- Target DB  : mmucc5 (pre-existing database built from database/mysql/ DDL)
-- Notes      : V1 handles fresh Testcontainers installs. V2 patches the live
--              mmucc5 database to match entity field types and nullability.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- APP_USER_TBL
-- Changes vs. original 30_APP_USER_TBL.sql:
--   1. AUS_USER_ID            INT UNSIGNED → BIGINT        (entity: Long)
--   2. AUS_PASSWORD_HASH      NOT NULL → NULL              (Firebase users have no local password)
--   3. AUS_FAILED_LOGIN_COUNT TINYINT UNSIGNED → INT       (entity: int)
--   4. ADD AUS_FIREBASE_UID   VARCHAR(128) NULL            (missing from original DDL)
--   5. ADD AUS_REFRESH_TOKEN_HASH  VARCHAR(255) NULL       (missing from original DDL)
--   6. ADD AUS_REFRESH_TOKEN_EXPIRY DATETIME NULL          (missing from original DDL)
--   7. ADD UNIQUE KEY on AUS_FIREBASE_UID
-- -----------------------------------------------------------------------------

ALTER TABLE APP_USER_TBL
    MODIFY COLUMN AUS_USER_ID               BIGINT          NOT NULL AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    MODIFY COLUMN AUS_PASSWORD_HASH         VARCHAR(255)    NULL                     COMMENT 'BCrypt hashed password. NULL for Firebase-only users.',
    MODIFY COLUMN AUS_FAILED_LOGIN_COUNT    INT             NOT NULL DEFAULT 0       COMMENT 'Consecutive failed login attempts (reset on success)',
    ADD COLUMN    AUS_FIREBASE_UID          VARCHAR(128)    NULL                     COMMENT 'Firebase Authentication UID. Primary linkage to Firebase.'
                  AFTER AUS_PASSWORD_HASH,
    ADD COLUMN    AUS_REFRESH_TOKEN_HASH    VARCHAR(255)    NULL                     COMMENT 'SHA-256 hex hash of the current refresh token. NULL when logged out.'
                  AFTER AUS_PASSWORD_RESET_EXPIRY,
    ADD COLUMN    AUS_REFRESH_TOKEN_EXPIRY  DATETIME        NULL                     COMMENT 'Expiry timestamp for the refresh token.'
                  AFTER AUS_REFRESH_TOKEN_HASH,
    ADD UNIQUE KEY UQ_AUS_FIREBASE_UID (AUS_FIREBASE_UID);

-- -----------------------------------------------------------------------------
-- CRASH_AUDIT_LOG_TBL
-- Changes vs. original 31_CRASH_AUDIT_LOG_TBL.sql:
--   1. CAL_CRASH_ID   INT UNSIGNED → INT   (entity: Integer — signed)
--   2. CAL_USER_ID    INT UNSIGNED → INT   (entity: Integer — signed)
--   3. CAL_RECORD_ID  INT UNSIGNED → INT   (entity: Integer — signed)
-- Note: CAL_AUDIT_ID remains BIGINT UNSIGNED — Long handles it fine.
-- -----------------------------------------------------------------------------

ALTER TABLE CRASH_AUDIT_LOG_TBL
    MODIFY COLUMN CAL_CRASH_ID   INT  NULL  COMMENT 'FK to CRASH_TBL (NULL for non-crash-scoped events such as user management)',
    MODIFY COLUMN CAL_USER_ID    INT  NULL  COMMENT 'FK to APP_USER_TBL; NULL for system-initiated events',
    MODIFY COLUMN CAL_RECORD_ID  INT  NULL  COMMENT 'PK value of the affected record in CAL_TABLE_NAME';
