-- =============================================================================
-- Table : CRASH_AUDIT_LOG_TBL
-- Acronym: CAL
-- Purpose: Immutable audit trail for all create/update/delete operations on
--          crash-related records. Written by application layer; never updated.
-- =============================================================================
CREATE TABLE CRASH_AUDIT_LOG_TBL (
    CAL_AUDIT_ID                    NUMBER(20)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_CAL PRIMARY KEY,
    CAL_CRASH_ID                    NUMBER(10),
    CAL_USER_ID                     NUMBER(10),
    CAL_USERNAME                    VARCHAR2(50)        NOT NULL,
    CAL_ACTION_CODE                 VARCHAR2(20)        NOT NULL,
    CAL_TABLE_NAME                  VARCHAR2(60)        NOT NULL,
    CAL_RECORD_ID                   NUMBER(10),
    CAL_OLD_VALUE                   CLOB,
    CAL_NEW_VALUE                   CLOB,
    CAL_IP_ADDRESS                  VARCHAR2(45),
    CAL_SESSION_ID                  VARCHAR2(100),

    -- Audit Columns (CREATED only - this table is append-only, never updated)
    CAL_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    CAL_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    CAL_MODIFIED_BY                 VARCHAR2(100),
    CAL_MODIFIED_DT                 DATE,
    CAL_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        DEFAULT 'CREATE' NOT NULL
);

COMMENT ON TABLE CRASH_AUDIT_LOG_TBL IS 'Immutable audit log of all data changes. Append-only; records are never updated or deleted.';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_AUDIT_ID IS 'Surrogate primary key (NUMBER(20) to accommodate high volume)';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_CRASH_ID IS 'FK to CRASH_TBL (NULL for non-crash-scoped events such as user management)';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_USER_ID IS 'FK to APP_USER_TBL; NULL for system-initiated events';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_USERNAME IS 'Snapshot of username at time of action (preserved even if user is deleted)';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_ACTION_CODE IS 'Operation performed. Values: CREATE=Record created, UPDATE=Record modified, DELETE=Record deleted, LOGIN=User login, LOGOUT=User logout, EXPORT=Data exported, IMPORT=Batch import performed';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_TABLE_NAME IS 'Name of the table that was modified (e.g., CRASH_TBL, VEHICLE_TBL)';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_RECORD_ID IS 'PK value of the affected record in CAL_TABLE_NAME';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_OLD_VALUE IS 'JSON snapshot of the row BEFORE the change (NULL for CREATE operations). Stored as CLOB.';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_NEW_VALUE IS 'JSON snapshot of the row AFTER the change (NULL for DELETE operations). Stored as CLOB.';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_IP_ADDRESS IS 'IPv4 or IPv6 address of the client that performed the action';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_SESSION_ID IS 'Application session identifier';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_MODIFIED_BY IS 'Always NULL - audit log entries are immutable';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_MODIFIED_DT IS 'Always NULL - audit log entries are immutable';
COMMENT ON COLUMN CRASH_AUDIT_LOG_TBL.CAL_LAST_UPDATED_ACTIVITY_CODE IS 'Always CREATE for audit log entries. Values: CREATE=Log entry creation';

CREATE INDEX IDX_CAL_CRASH_ID    ON CRASH_AUDIT_LOG_TBL (CAL_CRASH_ID);
CREATE INDEX IDX_CAL_USER_ID     ON CRASH_AUDIT_LOG_TBL (CAL_USER_ID);
CREATE INDEX IDX_CAL_CREATED_DT  ON CRASH_AUDIT_LOG_TBL (CAL_CREATED_DT);
CREATE INDEX IDX_CAL_TABLE_NAME  ON CRASH_AUDIT_LOG_TBL (CAL_TABLE_NAME);
CREATE INDEX IDX_CAL_ACTION_CODE ON CRASH_AUDIT_LOG_TBL (CAL_ACTION_CODE);
