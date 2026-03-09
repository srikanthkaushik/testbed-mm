-- =============================================================================
-- FILE:    07_CRASH_WEATHER_CONDITION_TBL.sql
-- PURPOSE: MMUCC C11 Weather Condition — multi-value child table
-- DBMS:    Oracle 19c
-- ACRONYM: CWC
-- =============================================================================

CREATE TABLE CRASH_WEATHER_CONDITION_TBL (
    CWC_ID                            NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_CWC PRIMARY KEY,
    CWC_CRASH_ID                      NUMBER(10)      NOT NULL,
    CWC_SEQUENCE_NUM                  NUMBER(3)       NOT NULL,
    CWC_WEATHER_CONDITION_CODE        NUMBER(3)       NOT NULL,
    -- Audit Columns
    CWC_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    CWC_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    CWC_MODIFIED_BY                   VARCHAR2(100),
    CWC_MODIFIED_DT                   DATE,
    CWC_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL,
    -- Table Constraints
    CONSTRAINT UQ_CWC_CRASH_SEQ UNIQUE (CWC_CRASH_ID, CWC_SEQUENCE_NUM)
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE CRASH_WEATHER_CONDITION_TBL IS 'MMUCC C11 Weather Condition. Multi-value child table — up to 4 weather conditions per crash.';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_ID                           IS 'Surrogate primary key for weather condition record.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_CRASH_ID                     IS 'FK to CRASH_TBL. Identifies the crash this weather condition applies to.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_SEQUENCE_NUM                 IS 'Entry sequence number (1-4). Indicates the order of multiple weather conditions recorded for a crash.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_WEATHER_CONDITION_CODE       IS 'C11: Weather condition at time of crash. 1=Clear, 2=Cloudy, 3=Rain, 4=Snow, 5=Fog/Smog/Smoke, 6=Sleet/Hail, 7=Blowing Snow, 8=Blowing Sand/Soil/Dirt, 9=Severe Crosswinds, 10=Freezing Rain or Drizzle, 98=Other, 99=Unknown.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_CREATED_BY                   IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_CREATED_DT                   IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_MODIFIED_BY                  IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_MODIFIED_DT                  IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN CRASH_WEATHER_CONDITION_TBL.CWC_LAST_UPDATED_ACTIVITY_CODE   IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_CWC_CRASH_ID ON CRASH_WEATHER_CONDITION_TBL (CWC_CRASH_ID);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE CRASH_WEATHER_CONDITION_TBL
    ADD CONSTRAINT FK_CWC_CRASH
    FOREIGN KEY (CWC_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
