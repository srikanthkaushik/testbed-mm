-- =============================================================================
-- Migration  : V1 – Auth service baseline schema
-- Service    : auth-service
-- Tables     : APP_USER_TBL, CRASH_AUDIT_LOG_TBL
-- Notes      : Includes Firebase support columns (AUS_FIREBASE_UID,
--              AUS_REFRESH_TOKEN_HASH, AUS_REFRESH_TOKEN_EXPIRY) from the start.
--              AUS_PASSWORD_HASH is nullable because Firebase manages credentials.
-- =============================================================================

CREATE TABLE IF NOT EXISTS APP_USER_TBL (
    AUS_USER_ID                     BIGINT              NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    AUS_USERNAME                    VARCHAR(50)         NOT NULL    COMMENT 'Unique login username',
    AUS_EMAIL                       VARCHAR(150)        NOT NULL    COMMENT 'Unique user email address',
    AUS_PASSWORD_HASH               VARCHAR(255)        NULL        COMMENT 'BCrypt hashed password. NULL for Firebase-only users.',
    AUS_FIREBASE_UID                VARCHAR(128)        NULL        COMMENT 'Firebase Authentication UID. Primary linkage to Firebase.',
    AUS_REFRESH_TOKEN_HASH          VARCHAR(255)        NULL        COMMENT 'SHA-256 hex hash of the current refresh token. NULL when logged out.',
    AUS_REFRESH_TOKEN_EXPIRY        DATETIME            NULL        COMMENT 'Expiry timestamp for the refresh token.',
    AUS_ROLE_CODE                   VARCHAR(20)         NOT NULL    COMMENT 'User role. Values: ADMIN=Full system administration, ANALYST=Read-only analysis and reporting, DATA_ENTRY=Create and edit crash records, VIEWER=Read-only access to crash records',
    AUS_AGENCY_CODE                 VARCHAR(20)         NULL        COMMENT 'Law enforcement agency or jurisdiction code',
    AUS_AGENCY_NAME                 VARCHAR(150)        NULL        COMMENT 'Full name of agency or jurisdiction',
    AUS_FIRST_NAME                  VARCHAR(75)         NULL        COMMENT 'User first name',
    AUS_LAST_NAME                   VARCHAR(75)         NULL        COMMENT 'User last name',
    AUS_IS_ACTIVE_FLG               TINYINT(1)          NOT NULL    DEFAULT 1 COMMENT 'Account active flag. Values: 1=Active, 0=Disabled',
    AUS_LAST_LOGIN_DT               DATETIME            NULL        COMMENT 'Timestamp of last successful login',
    AUS_FAILED_LOGIN_COUNT          INT                 NOT NULL    DEFAULT 0 COMMENT 'Consecutive failed login attempts (reset on success)',
    AUS_ACCOUNT_LOCKED_FLG          TINYINT(1)          NOT NULL    DEFAULT 0 COMMENT 'Account locked flag. Values: 1=Locked, 0=Not Locked',
    AUS_PASSWORD_RESET_TOKEN        VARCHAR(255)        NULL        COMMENT 'One-time password reset token (hashed); cleared after use',
    AUS_PASSWORD_RESET_EXPIRY       DATETIME            NULL        COMMENT 'Expiry timestamp for the password reset token',

    -- Audit Columns
    AUS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    AUS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    AUS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    AUS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    AUS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed',

    PRIMARY KEY (AUS_USER_ID),
    UNIQUE KEY UQ_AUS_USERNAME      (AUS_USERNAME),
    UNIQUE KEY UQ_AUS_EMAIL         (AUS_EMAIL),
    UNIQUE KEY UQ_AUS_FIREBASE_UID  (AUS_FIREBASE_UID),
    INDEX IDX_AUS_AGENCY_CODE       (AUS_AGENCY_CODE),
    INDEX IDX_AUS_ROLE              (AUS_ROLE_CODE),
    INDEX IDX_AUS_IS_ACTIVE         (AUS_IS_ACTIVE_FLG)
) ENGINE=InnoDB COMMENT='Application user accounts with Firebase Authentication integration.';


CREATE TABLE IF NOT EXISTS CRASH_AUDIT_LOG_TBL (
    CAL_AUDIT_ID                    BIGINT UNSIGNED     NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    CAL_CRASH_ID                    INT UNSIGNED        NULL        COMMENT 'FK to CRASH_TBL (NULL for non-crash events such as LOGIN/LOGOUT)',
    CAL_USER_ID                     INT UNSIGNED        NULL        COMMENT 'FK to APP_USER_TBL; NULL for system events',
    CAL_USERNAME                    VARCHAR(50)         NOT NULL    COMMENT 'Snapshot of username at time of action',
    CAL_ACTION_CODE                 VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE, UPDATE, DELETE, LOGIN, LOGOUT, EXPORT, IMPORT',
    CAL_TABLE_NAME                  VARCHAR(60)         NOT NULL    COMMENT 'Name of the table that was modified',
    CAL_RECORD_ID                   INT UNSIGNED        NULL        COMMENT 'PK value of the affected record',
    CAL_OLD_VALUE                   JSON                NULL        COMMENT 'Row snapshot BEFORE the change (NULL for CREATE)',
    CAL_NEW_VALUE                   JSON                NULL        COMMENT 'Row snapshot AFTER the change (NULL for DELETE)',
    CAL_IP_ADDRESS                  VARCHAR(45)         NULL        COMMENT 'IPv4 or IPv6 address of the client',
    CAL_SESSION_ID                  VARCHAR(100)        NULL        COMMENT 'Application session identifier',

    -- Audit Columns (append-only: modified columns are always NULL)
    CAL_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User that created this log entry',
    CAL_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when this entry was written',
    CAL_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'Always NULL – audit log is immutable',
    CAL_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Always NULL – audit log is immutable',
    CAL_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    DEFAULT 'CREATE' COMMENT 'Always CREATE for audit log entries',

    PRIMARY KEY (CAL_AUDIT_ID),
    INDEX IDX_CAL_CRASH_ID          (CAL_CRASH_ID),
    INDEX IDX_CAL_USER_ID           (CAL_USER_ID),
    INDEX IDX_CAL_CREATED_DT        (CAL_CREATED_DT),
    INDEX IDX_CAL_TABLE_NAME        (CAL_TABLE_NAME),
    INDEX IDX_CAL_ACTION_CODE       (CAL_ACTION_CODE)
) ENGINE=InnoDB COMMENT='Immutable audit log. Append-only; records are never updated or deleted.';
