-- =============================================================================
-- FILE:    08_CRASH_SURFACE_CONDITION_TBL.sql
-- PURPOSE: MMUCC C13 Surface Condition — multi-value child table
-- DBMS:    Oracle 19c
-- ACRONYM: CSC
-- =============================================================================

CREATE TABLE CRASH_SURFACE_CONDITION_TBL (
    CSC_ID                            NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_CSC PRIMARY KEY,
    CSC_CRASH_ID                      NUMBER(10)      NOT NULL,
    CSC_SEQUENCE_NUM                  NUMBER(3)       NOT NULL,
    CSC_SURFACE_CONDITION_CODE        NUMBER(3)       NOT NULL,
    -- Audit Columns
    CSC_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    CSC_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    CSC_MODIFIED_BY                   VARCHAR2(100),
    CSC_MODIFIED_DT                   DATE,
    CSC_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL,
    -- Table Constraints
    CONSTRAINT UQ_CSC_CRASH_SEQ UNIQUE (CSC_CRASH_ID, CSC_SEQUENCE_NUM)
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE CRASH_SURFACE_CONDITION_TBL IS 'MMUCC C13 Surface Condition. Multi-value child table — up to 4 surface conditions per crash.';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_ID                           IS 'Surrogate primary key for surface condition record.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_CRASH_ID                     IS 'FK to CRASH_TBL. Identifies the crash this surface condition applies to.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_SEQUENCE_NUM                 IS 'Entry sequence number (1-4). Indicates the order of multiple surface conditions recorded for a crash.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_SURFACE_CONDITION_CODE       IS 'C13: Roadway surface condition at time of crash. 1=Dry, 2=Wet, 3=Snow or Slush, 4=Ice, 5=Sand/Mud/Dirt/Oil/Gravel, 6=Water (Standing or Moving), 7=Oil, 98=Other, 99=Unknown.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_CREATED_BY                   IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_CREATED_DT                   IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_MODIFIED_BY                  IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_MODIFIED_DT                  IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN CRASH_SURFACE_CONDITION_TBL.CSC_LAST_UPDATED_ACTIVITY_CODE   IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_CSC_CRASH_ID ON CRASH_SURFACE_CONDITION_TBL (CSC_CRASH_ID);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE CRASH_SURFACE_CONDITION_TBL
    ADD CONSTRAINT FK_CSC_CRASH
    FOREIGN KEY (CSC_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
