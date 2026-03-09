-- =============================================================================
-- FILE:    17_FATAL_SECTION_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   FATAL_SECTION_TBL (FSC)
-- PURPOSE: MMUCC F1-F3 - Fatal Section. One record per fatal person
--          (injury status = 1/Fatal). Captures lag days to death, death
--          date/time, work-relatedness, and restraint/helmet usage.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE FATAL_SECTION_TBL (

    FSC_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_FSC PRIMARY KEY,

    -- One-to-one with PERSON_TBL; enforced by unique constraint below.
    FSC_PERSON_ID                   NUMBER(10)      NOT NULL,
    FSC_CRASH_ID                    NUMBER(10)      NOT NULL,

    -- F1: Days Between Crash and Death.
    --   0      = Died at scene or same day
    --   1-29   = Died 1-29 days after crash
    --   30     = Died 30 or more days after crash
    --   NULL   = Survival interval unknown or not yet determined
    FSC_LAG_DAYS                    NUMBER(5),

    -- F1 derived: Actual calendar date of death.
    -- NULL until death is confirmed.
    FSC_DEATH_DATE                  DATE,

    -- F1 derived: Time of death in HH:MM (24-hour) format.
    -- Stored as VARCHAR2 to accommodate unknown/partial time entries
    -- (e.g., '99:99' = unknown).
    -- NULL until death time is confirmed.
    FSC_DEATH_TIME                  VARCHAR2(5),

    -- F2: Work-Related Fatality:
    --   1  = No
    --   2  = Yes
    --  99  = Unknown
    FSC_WORK_RELATED_CODE           NUMBER(3),

    -- F3: Restraint System / Helmet Use at Time of Fatal Injury:
    --   1  = Lap Belt Used
    --   2  = Shoulder and Lap Belt Used
    --   3  = Shoulder Belt Only Used
    --   4  = Booster Seat Used
    --   5  = Child Restraint Used (other)
    --   6  = Helmet Used
    --   7  = Protective Pads / Clothing
    --   8  = Reflective Clothing / Equipment
    --   9  = None Used
    --  10  = Unknown
    FSC_RESTRAINT_HELMET_CODE       NUMBER(3),

    -- Audit columns
    FSC_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    FSC_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    FSC_MODIFIED_BY                 VARCHAR2(100),
    FSC_MODIFIED_DT                 DATE,
    FSC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    -- One FSC record per fatal person (1:1 with PERSON_TBL for fatals)
    CONSTRAINT UQ_FSC_PERSON_ID UNIQUE (FSC_PERSON_ID)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE FATAL_SECTION_TBL IS
    'MMUCC F1-F3 - Fatal Section. One record per fatally injured person (injury status = 1). Captures death lag days, death date and time, work-relatedness of the fatality, and restraint/helmet use at time of fatal injury.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_PERSON_ID IS
    'Foreign key to PERSON_TBL. One-to-one: only one FSC record may exist per fatal person, enforced by UQ_FSC_PERSON_ID.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level fatality queries without joining through PERSON_TBL.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_LAG_DAYS IS
    'MMUCC F1 - Days Between Crash and Death. 0=Died at scene or same day; 1-29=Died within that many days; 30=Died 30 or more days after crash; NULL=unknown survival interval.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_DEATH_DATE IS
    'F1 derived: Actual calendar date of death. NULL until death is confirmed.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_DEATH_TIME IS
    'F1 derived: Time of death in HH:MM (24-hour) format. ''99:99'' indicates unknown time. NULL until death time is confirmed.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_WORK_RELATED_CODE IS
    'MMUCC F2 - Work-Related Fatality indicator. 1=No; 2=Yes; 99=Unknown. NULL if not yet determined.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_RESTRAINT_HELMET_CODE IS
    'MMUCC F3 - Restraint System / Helmet Use at time of fatal injury. 1=Lap Belt Used; 2=Shoulder and Lap Belt Used; 3=Shoulder Belt Only Used; 4=Booster Seat Used; 5=Child Restraint Used (other); 6=Helmet Used; 7=Protective Pads/Clothing; 8=Reflective Clothing/Equipment; 9=None Used; 10=Unknown.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN FATAL_SECTION_TBL.FSC_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

-- FSC_PERSON_ID is already covered by the unique constraint index;
-- a separate index on FSC_CRASH_ID supports crash-level fatality reporting.
CREATE INDEX IDX_FSC_CRASH_ID ON FATAL_SECTION_TBL (FSC_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE FATAL_SECTION_TBL
    ADD CONSTRAINT FK_FSC_PERSON
        FOREIGN KEY (FSC_PERSON_ID)
        REFERENCES PERSON_TBL (PRS_ID)
        ON DELETE CASCADE;

ALTER TABLE FATAL_SECTION_TBL
    ADD CONSTRAINT FK_FSC_CRASH
        FOREIGN KEY (FSC_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
