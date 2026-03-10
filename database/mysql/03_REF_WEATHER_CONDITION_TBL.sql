-- =============================================================================
-- Table : REF_WEATHER_CONDITION_TBL
-- Acronym: RWC
-- Source : MMUCC v5 C11 - Weather Conditions
-- =============================================================================
CREATE TABLE REF_WEATHER_CONDITION_TBL (
    RWC_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RWC_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for weather condition',
    RWC_DESCRIPTION                 VARCHAR(80)         NOT NULL    COMMENT 'Human-readable weather condition',

    -- Audit Columns
    RWC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RWC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RWC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RWC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RWC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RWC_ID),
    UNIQUE KEY UQ_RWC_CODE (RWC_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC C11 Weather Conditions lookup values';

INSERT INTO REF_WEATHER_CONDITION_TBL (RWC_CODE, RWC_DESCRIPTION, RWC_CREATED_BY, RWC_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1,  'Clear',                           'SYSTEM', 'IMPORT'),
(2,  'Cloudy',                          'SYSTEM', 'IMPORT'),
(3,  'Rain',                            'SYSTEM', 'IMPORT'),
(4,  'Snow',                            'SYSTEM', 'IMPORT'),
(5,  'Fog, Smog, Smoke',                'SYSTEM', 'IMPORT'),
(6,  'Sleet, Hail',                     'SYSTEM', 'IMPORT'),
(7,  'Blowing Snow',                    'SYSTEM', 'IMPORT'),
(8,  'Blowing Sand, Soil, Dirt',        'SYSTEM', 'IMPORT'),
(9,  'Severe Crosswinds',               'SYSTEM', 'IMPORT'),
(10, 'Freezing Rain or Drizzle',        'SYSTEM', 'IMPORT'),
(98, 'Other',                           'SYSTEM', 'IMPORT'),
(99, 'Unknown',                         'SYSTEM', 'IMPORT');
