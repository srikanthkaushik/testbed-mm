-- =============================================================================
-- Table : CRASH_WEATHER_CONDITION_TBL
-- Acronym: CWC
-- Source : MMUCC v5 C11 - Weather Conditions (select 1-4)
-- Notes : Child of CRASH_TBL. Up to 4 weather conditions per crash.
-- =============================================================================
CREATE TABLE CRASH_WEATHER_CONDITION_TBL (
    CWC_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    CWC_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL',
    CWC_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 weather conditions per crash.',
    CWC_WEATHER_CODE                TINYINT UNSIGNED    NOT NULL    COMMENT 'C11: FK to REF_WEATHER_CONDITION_TBL. Values: 1=Clear, 2=Cloudy, 3=Rain, 4=Snow, 5=Fog/Smog/Smoke, 6=Sleet/Hail, 7=Blowing Snow, 8=Blowing Sand/Soil/Dirt, 9=Severe Crosswinds, 10=Freezing Rain or Drizzle, 98=Other, 99=Unknown',

    -- Audit Columns
    CWC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    CWC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    CWC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    CWC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    CWC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (CWC_ID),
    UNIQUE KEY UQ_CWC_CRASH_SEQ     (CWC_CRASH_ID, CWC_SEQUENCE_NUM),
    INDEX IDX_CWC_CRASH_ID          (CWC_CRASH_ID),
    INDEX IDX_CWC_WEATHER_CODE      (CWC_WEATHER_CODE),
    CONSTRAINT FK_CWC_CRASH FOREIGN KEY (CWC_CRASH_ID) REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC C11: Weather Conditions. Multi-value child of CRASH_TBL (up to 4 per crash).';
