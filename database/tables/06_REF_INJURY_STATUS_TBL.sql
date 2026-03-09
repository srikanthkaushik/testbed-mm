-- =============================================================================
-- Table : REF_INJURY_STATUS_TBL
-- Acronym: RIS
-- Source : MMUCC v5 P5 - Injury Status
-- =============================================================================
CREATE TABLE REF_INJURY_STATUS_TBL (
    RIS_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RIS_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for injury status',
    RIS_KABCO_LETTER                CHAR(1)             NULL        COMMENT 'KABCO letter designation: K=Fatal, A=Suspected Serious, B=Suspected Minor, C=Possible, O=No Apparent',
    RIS_DESCRIPTION                 VARCHAR(100)        NOT NULL    COMMENT 'Human-readable injury status',
    RIS_REQUIRES_FATAL_SECTION      TINYINT(1)          NOT NULL    DEFAULT 0 COMMENT '1=Fatal Section (F1-F3) must be completed; 0=Not required',

    -- Audit Columns
    RIS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RIS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RIS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RIS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RIS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RIS_ID),
    UNIQUE KEY UQ_RIS_CODE (RIS_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC P5 Injury Status lookup values';

INSERT INTO REF_INJURY_STATUS_TBL (RIS_CODE, RIS_KABCO_LETTER, RIS_DESCRIPTION, RIS_REQUIRES_FATAL_SECTION, RIS_CREATED_BY, RIS_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1, 'K', '(K) Fatal Injury',              1, 'SYSTEM', 'IMPORT'),
(2, 'A', '(A) Suspected Serious Injury',  0, 'SYSTEM', 'IMPORT'),
(3, 'B', '(B) Suspected Minor Injury',    0, 'SYSTEM', 'IMPORT'),
(4, 'C', '(C) Possible Injury',           0, 'SYSTEM', 'IMPORT'),
(5, 'O', '(O) No Apparent Injury',        0, 'SYSTEM', 'IMPORT');
