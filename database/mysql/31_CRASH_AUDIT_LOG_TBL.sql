-- =============================================================================
-- Table : CRASH_AUDIT_LOG_TBL
-- Acronym: CAL
-- Purpose: Immutable audit trail for all create/update/delete operations on
--          crash-related records. Written by application layer; never updated.
-- =============================================================================
CREATE TABLE CRASH_AUDIT_LOG_TBL (
    CAL_AUDIT_ID                    BIGINT UNSIGNED     NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key (BIGINT to accommodate high volume)',
    CAL_CRASH_ID                    INT UNSIGNED        NULL        COMMENT 'FK to CRASH_TBL (NULL for non-crash-scoped events such as user management)',
    CAL_USER_ID                     INT UNSIGNED        NULL        COMMENT 'FK to APP_USER_TBL; NULL for system-initiated events',
    CAL_USERNAME                    VARCHAR(50)         NOT NULL    COMMENT 'Snapshot of username at time of action (preserved even if user is deleted)',
    CAL_ACTION_CODE                 VARCHAR(20)         NOT NULL    COMMENT 'Operation performed. Values: CREATE=Record created, UPDATE=Record modified, DELETE=Record deleted, LOGIN=User login, LOGOUT=User logout, EXPORT=Data exported, IMPORT=Batch import performed',
    CAL_TABLE_NAME                  VARCHAR(60)         NOT NULL    COMMENT 'Name of the table that was modified (e.g., CRASH_TBL, VEHICLE_TBL)',
    CAL_RECORD_ID                   INT UNSIGNED        NULL        COMMENT 'PK value of the affected record in CAL_TABLE_NAME',
    CAL_OLD_VALUE                   JSON                NULL        COMMENT 'JSON snapshot of the row BEFORE the change (NULL for CREATE operations)',
    CAL_NEW_VALUE                   JSON                NULL        COMMENT 'JSON snapshot of the row AFTER the change (NULL for DELETE operations)',
    CAL_IP_ADDRESS                  VARCHAR(45)         NULL        COMMENT 'IPv4 or IPv6 address of the client that performed the action',
    CAL_SESSION_ID                  VARCHAR(100)        NULL        COMMENT 'Application session identifier',

    -- Audit Columns (CREATED only - this table is append-only, never updated)
    CAL_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this log entry',
    CAL_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when this audit log entry was written',
    CAL_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'Always NULL - audit log entries are immutable',
    CAL_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Always NULL - audit log entries are immutable',
    CAL_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    DEFAULT 'CREATE' COMMENT 'Always CREATE for audit log entries. Values: CREATE=Log entry creation',

    PRIMARY KEY (CAL_AUDIT_ID),
    INDEX IDX_CAL_CRASH_ID          (CAL_CRASH_ID),
    INDEX IDX_CAL_USER_ID           (CAL_USER_ID),
    INDEX IDX_CAL_CREATED_DT        (CAL_CREATED_DT),
    INDEX IDX_CAL_TABLE_NAME        (CAL_TABLE_NAME),
    INDEX IDX_CAL_ACTION_CODE       (CAL_ACTION_CODE)
) ENGINE=InnoDB COMMENT='Immutable audit log of all data changes. Append-only; records are never updated or deleted.';
