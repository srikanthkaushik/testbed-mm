-- =============================================================================
-- Table : APP_USER_TBL
-- Acronym: AUS
-- Purpose: Application user accounts for authentication and authorization.
--          Stores users for the Angular/Spring Boot web application.
-- =============================================================================
CREATE TABLE APP_USER_TBL (
    AUS_USER_ID                     NUMBER(10)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_AUS PRIMARY KEY,
    AUS_USERNAME                    VARCHAR2(50)        NOT NULL,
    AUS_EMAIL                       VARCHAR2(150)       NOT NULL,
    AUS_PASSWORD_HASH               VARCHAR2(255)       NOT NULL,
    AUS_ROLE_CODE                   VARCHAR2(20)        NOT NULL,
    AUS_AGENCY_CODE                 VARCHAR2(20),
    AUS_AGENCY_NAME                 VARCHAR2(150),
    AUS_FIRST_NAME                  VARCHAR2(75),
    AUS_LAST_NAME                   VARCHAR2(75),
    AUS_IS_ACTIVE_FLG               NUMBER(1)           DEFAULT 1 NOT NULL,
    AUS_LAST_LOGIN_DT               DATE,
    AUS_FAILED_LOGIN_COUNT          NUMBER(3)           DEFAULT 0 NOT NULL,
    AUS_ACCOUNT_LOCKED_FLG          NUMBER(1)           DEFAULT 0 NOT NULL,
    AUS_PASSWORD_RESET_TOKEN        VARCHAR2(255),
    AUS_PASSWORD_RESET_EXPIRY       DATE,

    -- Audit Columns
    AUS_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    AUS_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    AUS_MODIFIED_BY                 VARCHAR2(100),
    AUS_MODIFIED_DT                 DATE,
    AUS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        NOT NULL,

    CONSTRAINT UQ_AUS_USERNAME      UNIQUE (AUS_USERNAME),
    CONSTRAINT UQ_AUS_EMAIL         UNIQUE (AUS_EMAIL)
);

COMMENT ON TABLE APP_USER_TBL IS 'Application user accounts for Spring Boot/Angular authentication and authorization.';
COMMENT ON COLUMN APP_USER_TBL.AUS_USERNAME IS 'Unique login username';
COMMENT ON COLUMN APP_USER_TBL.AUS_EMAIL IS 'Unique user email address';
COMMENT ON COLUMN APP_USER_TBL.AUS_PASSWORD_HASH IS 'BCrypt hashed password (never store plaintext)';
COMMENT ON COLUMN APP_USER_TBL.AUS_ROLE_CODE IS 'User role. Values: ADMIN=Full system administration, ANALYST=Read-only analysis and reporting, DATA_ENTRY=Create and edit crash records, VIEWER=Read-only access to crash records';
COMMENT ON COLUMN APP_USER_TBL.AUS_AGENCY_CODE IS 'Law enforcement agency or jurisdiction code that this user belongs to';
COMMENT ON COLUMN APP_USER_TBL.AUS_IS_ACTIVE_FLG IS 'Account active flag. Values: 1=Active, 0=Disabled/Deactivated';
COMMENT ON COLUMN APP_USER_TBL.AUS_FAILED_LOGIN_COUNT IS 'Count of consecutive failed login attempts (reset on success)';
COMMENT ON COLUMN APP_USER_TBL.AUS_ACCOUNT_LOCKED_FLG IS 'Account locked due to failed attempts. Values: 1=Locked, 0=Not Locked';
COMMENT ON COLUMN APP_USER_TBL.AUS_PASSWORD_RESET_TOKEN IS 'One-time password reset token (hashed); cleared after use';
COMMENT ON COLUMN APP_USER_TBL.AUS_PASSWORD_RESET_EXPIRY IS 'Expiry timestamp for the password reset token';
COMMENT ON COLUMN APP_USER_TBL.AUS_LAST_UPDATED_ACTIVITY_CODE IS 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved';

CREATE INDEX IDX_AUS_AGENCY_CODE ON APP_USER_TBL (AUS_AGENCY_CODE);
CREATE INDEX IDX_AUS_ROLE        ON APP_USER_TBL (AUS_ROLE_CODE);
CREATE INDEX IDX_AUS_IS_ACTIVE   ON APP_USER_TBL (AUS_IS_ACTIVE_FLG);
