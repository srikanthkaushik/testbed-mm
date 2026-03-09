-- =============================================================================
-- FILE:    09_CRASH_CONTRIBUTING_ROADWAY_TBL.sql
-- PURPOSE: MMUCC C14 Contributing Circumstances – Roadway — multi-value child table
-- DBMS:    Oracle 19c
-- ACRONYM: CCR
-- =============================================================================

CREATE TABLE CRASH_CONTRIBUTING_ROADWAY_TBL (
    CCR_ID                            NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_CCR PRIMARY KEY,
    CCR_CRASH_ID                      NUMBER(10)      NOT NULL,
    CCR_SEQUENCE_NUM                  NUMBER(3)       NOT NULL,
    CCR_CONTRIBUTING_CIRC_CODE        NUMBER(3)       NOT NULL,
    -- Audit Columns
    CCR_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    CCR_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    CCR_MODIFIED_BY                   VARCHAR2(100),
    CCR_MODIFIED_DT                   DATE,
    CCR_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL,
    -- Table Constraints
    CONSTRAINT UQ_CCR_CRASH_SEQ UNIQUE (CCR_CRASH_ID, CCR_SEQUENCE_NUM)
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE CRASH_CONTRIBUTING_ROADWAY_TBL IS 'MMUCC C14 Contributing Circumstances – Roadway. Multi-value child table — up to 2 roadway contributing circumstances per crash.';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_ID                           IS 'Surrogate primary key for contributing roadway circumstance record.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_CRASH_ID                     IS 'FK to CRASH_TBL. Identifies the crash this contributing circumstance applies to.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_SEQUENCE_NUM                 IS 'Entry sequence number (1-2). Indicates the order of multiple contributing roadway circumstances recorded for a crash.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_CONTRIBUTING_CIRC_CODE       IS 'C14: Contributing circumstance related to roadway. 0=None, 1=Debris on Roadway, 2=Erosion/Ruts/Holes/Bumps, 3=Fixed Object in Roadway, 4=Ice/Frost on Roadway, 5=Non-Highway Work, 6=Obstruction in Roadway, 7=Pavement Defective, 8=Pavement Slippery, 9=Reduction in Roadway Width, 10=Road Under Construction/Maintenance, 11=Ruts/Holes/Bumps, 12=Shoulders Defective/Absent, 13=Snow on Roadway, 14=Traffic Control Device Defective/Missing/Obscured, 15=Worn/Travel Polished Surface, 98=Other, 99=Unknown.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_CREATED_BY                   IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_CREATED_DT                   IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_MODIFIED_BY                  IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_MODIFIED_DT                  IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN CRASH_CONTRIBUTING_ROADWAY_TBL.CCR_LAST_UPDATED_ACTIVITY_CODE   IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_CCR_CRASH_ID ON CRASH_CONTRIBUTING_ROADWAY_TBL (CCR_CRASH_ID);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE CRASH_CONTRIBUTING_ROADWAY_TBL
    ADD CONSTRAINT FK_CCR_CRASH
    FOREIGN KEY (CCR_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
