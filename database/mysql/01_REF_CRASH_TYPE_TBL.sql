-- =============================================================================
-- Table : REF_CRASH_TYPE_TBL
-- Acronym: RCT
-- Source : MMUCC v5 C2 Subfield 1 - Crash Classification: Crash Type
-- =============================================================================
CREATE TABLE REF_CRASH_TYPE_TBL (
    RCT_ID                          TINYINT UNSIGNED    NOT NULL,
    RCT_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for crash type',
    RCT_DESCRIPTION                 VARCHAR(100)        NOT NULL    COMMENT 'Human-readable description of crash type',

    -- Audit Columns
    RCT_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RCT_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RCT_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RCT_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RCT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RCT_ID),
    UNIQUE KEY UQ_RCT_CODE (RCT_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC C2 SF1 Crash Type lookup values';

INSERT INTO REF_CRASH_TYPE_TBL (RCT_ID, RCT_CODE, RCT_DESCRIPTION, RCT_CREATED_BY, RCT_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1,  1,  'Single Vehicle',                  'SYSTEM', 'IMPORT'),
(2,  2,  'Two Vehicle - Same Direction',    'SYSTEM', 'IMPORT'),
(3,  3,  'Two Vehicle - Opposite Direction','SYSTEM', 'IMPORT'),
(4,  4,  'Two Vehicle - Intersecting Direction', 'SYSTEM', 'IMPORT'),
(5,  5,  'Two Vehicle - Other',             'SYSTEM', 'IMPORT'),
(6,  6,  'Three or More Vehicle',           'SYSTEM', 'IMPORT'),
(7,  99, 'Unknown',                         'SYSTEM', 'IMPORT');
