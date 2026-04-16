-- =============================================================================
-- Table : APP_USER_TBL
-- Acronym: AUS
-- Purpose: Application user accounts for authentication and authorization.
--          Stores users for the Angular/Spring Boot web application.
-- =============================================================================
CREATE TABLE APP_USER_TBL (
    AUS_USER_ID                     INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    AUS_USERNAME                    VARCHAR(50)         NOT NULL    COMMENT 'Unique login username',
    AUS_EMAIL                       VARCHAR(150)        NOT NULL    COMMENT 'Unique user email address',
    AUS_PASSWORD_HASH               VARCHAR(255)        NULL        COMMENT 'BCrypt hashed password; NULL for Firebase-only users',
    AUS_FIREBASE_UID                VARCHAR(128)        NULL        COMMENT 'Firebase Authentication UID — primary linkage between Firebase and this app',
    AUS_ROLE_CODE                   VARCHAR(20)         NOT NULL    COMMENT 'User role. Values: ADMIN=Full system administration, ANALYST=Read-only analysis and reporting, DATA_ENTRY=Create and edit crash records, VIEWER=Read-only access to crash records',
    AUS_AGENCY_CODE                 VARCHAR(20)         NULL        COMMENT 'Law enforcement agency or jurisdiction code that this user belongs to',
    AUS_AGENCY_NAME                 VARCHAR(150)        NULL        COMMENT 'Full name of agency or jurisdiction',
    AUS_FIRST_NAME                  VARCHAR(75)         NULL        COMMENT 'User first name',
    AUS_LAST_NAME                   VARCHAR(75)         NULL        COMMENT 'User last name',
    AUS_IS_ACTIVE_FLG               TINYINT(1)          NOT NULL    DEFAULT 1 COMMENT 'Account active flag. Values: 1=Active, 0=Disabled/Deactivated',
    AUS_LAST_LOGIN_DT               DATETIME            NULL        COMMENT 'Timestamp of last successful login',
    AUS_FAILED_LOGIN_COUNT          TINYINT UNSIGNED    NOT NULL    DEFAULT 0 COMMENT 'Count of consecutive failed login attempts (reset on success)',
    AUS_ACCOUNT_LOCKED_FLG          TINYINT(1)          NOT NULL    DEFAULT 0 COMMENT 'Account locked due to failed attempts. Values: 1=Locked, 0=Not Locked',
    AUS_PASSWORD_RESET_TOKEN        VARCHAR(255)        NULL        COMMENT 'One-time password reset token (hashed); cleared after use',
    AUS_PASSWORD_RESET_EXPIRY       DATETIME            NULL        COMMENT 'Expiry timestamp for the password reset token',
    AUS_REFRESH_TOKEN_HASH          VARCHAR(255)        NULL        COMMENT 'SHA-256 hex hash of the current refresh token; NULL when logged out',
    AUS_REFRESH_TOKEN_EXPIRY        DATETIME            NULL        COMMENT 'Expiry timestamp for the refresh token',

    -- Audit Columns
    AUS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    AUS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    AUS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    AUS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    AUS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (AUS_USER_ID),
    UNIQUE KEY UQ_AUS_USERNAME      (AUS_USERNAME),
    UNIQUE KEY UQ_AUS_EMAIL         (AUS_EMAIL),
    UNIQUE KEY UQ_AUS_FIREBASE_UID  (AUS_FIREBASE_UID),
    INDEX IDX_AUS_AGENCY_CODE       (AUS_AGENCY_CODE),
    INDEX IDX_AUS_ROLE              (AUS_ROLE_CODE),
    INDEX IDX_AUS_IS_ACTIVE         (AUS_IS_ACTIVE_FLG)
) ENGINE=InnoDB COMMENT='Application user accounts for Spring Boot/Angular authentication and authorization.';
