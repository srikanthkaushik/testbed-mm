-- =============================================================================
-- Table : REF_PERSON_TYPE_TBL
-- Acronym: RPT
-- Source : MMUCC v5 P4 Subfield 1 - Person Type
-- =============================================================================
CREATE TABLE REF_PERSON_TYPE_TBL (
    RPT_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RPT_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for person type',
    RPT_DESCRIPTION                 VARCHAR(100)        NOT NULL    COMMENT 'Human-readable person type',
    RPT_IS_NON_MOTORIST             TINYINT(1)          NOT NULL    DEFAULT 0 COMMENT '1=Non-Motorist section must be completed for this type; 0=Not required',

    -- Audit Columns
    RPT_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RPT_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RPT_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RPT_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RPT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RPT_ID),
    UNIQUE KEY UQ_RPT_CODE (RPT_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC P4 SF1 Person Type lookup values';

INSERT INTO REF_PERSON_TYPE_TBL (RPT_CODE, RPT_DESCRIPTION, RPT_IS_NON_MOTORIST, RPT_CREATED_BY, RPT_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1,  'Driver',                                                      0, 'SYSTEM', 'IMPORT'),
(2,  'Passenger',                                                   0, 'SYSTEM', 'IMPORT'),
(3,  'Occupant of MV Not in Transport',                             0, 'SYSTEM', 'IMPORT'),
(4,  'Bicyclist',                                                   1, 'SYSTEM', 'IMPORT'),
(5,  'Other Cyclist',                                               1, 'SYSTEM', 'IMPORT'),
(6,  'Pedestrian',                                                  1, 'SYSTEM', 'IMPORT'),
(7,  'Other Pedestrian (wheelchair, skater, personal conveyance)',  1, 'SYSTEM', 'IMPORT'),
(8,  'Occupant of Non-Motor Vehicle Transportation Device',         1, 'SYSTEM', 'IMPORT'),
(9,  'Unknown Type of Non-Motorist',                                1, 'SYSTEM', 'IMPORT'),
(99, 'Unknown',                                                     0, 'SYSTEM', 'IMPORT');
