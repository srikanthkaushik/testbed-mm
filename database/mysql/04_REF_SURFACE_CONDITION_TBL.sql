-- =============================================================================
-- Table : REF_SURFACE_CONDITION_TBL
-- Acronym: RSC
-- Source : MMUCC v5 C13 - Roadway Surface Condition
-- =============================================================================
CREATE TABLE REF_SURFACE_CONDITION_TBL (
    RSC_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RSC_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for roadway surface condition',
    RSC_DESCRIPTION                 VARCHAR(80)         NOT NULL    COMMENT 'Human-readable surface condition',

    -- Audit Columns
    RSC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RSC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RSC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RSC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RSC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RSC_ID),
    UNIQUE KEY UQ_RSC_CODE (RSC_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC C13 Roadway Surface Condition lookup values';

INSERT INTO REF_SURFACE_CONDITION_TBL (RSC_CODE, RSC_DESCRIPTION, RSC_CREATED_BY, RSC_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1,  'Dry',                                 'SYSTEM', 'IMPORT'),
(2,  'Wet',                                 'SYSTEM', 'IMPORT'),
(3,  'Snow or Slush',                       'SYSTEM', 'IMPORT'),
(4,  'Ice',                                 'SYSTEM', 'IMPORT'),
(5,  'Sand, Mud, Dirt, Oil, Gravel',        'SYSTEM', 'IMPORT'),
(6,  'Water (Standing or Moving)',          'SYSTEM', 'IMPORT'),
(7,  'Oil',                                 'SYSTEM', 'IMPORT'),
(98, 'Other',                               'SYSTEM', 'IMPORT'),
(99, 'Unknown',                             'SYSTEM', 'IMPORT');
