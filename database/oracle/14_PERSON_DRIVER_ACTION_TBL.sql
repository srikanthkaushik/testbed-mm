-- =============================================================================
-- FILE:    14_PERSON_DRIVER_ACTION_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   PERSON_DRIVER_ACTION_TBL (PDA)
-- PURPOSE: MMUCC P14 - Driver Actions/Circumstances Contributing to Crash.
--          Up to 4 contributing actions recorded per driver.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE PERSON_DRIVER_ACTION_TBL (

    PDA_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_PDA PRIMARY KEY,

    PDA_PERSON_ID                   NUMBER(10)      NOT NULL,
    PDA_CRASH_ID                    NUMBER(10)      NOT NULL,
    PDA_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- P14 Driver Actions/Circumstances Contributing to Crash:
    --   0  = No Improper Action
    --   1  = Improper Turn
    --   2  = Improper Lane Change
    --   3  = Improper Backing
    --   4  = Improper Passing
    --   5  = Following Too Closely
    --   6  = Ran Off Road
    --   7  = Ran Stop Sign
    --   8  = Ran Red Light
    --   9  = Exceeded Speed Limit
    --  10  = Operating Vehicle Erratically (reckless, aggressive, etc.)
    --  11  = Swerved or Avoided (due to wind, slippery surface, vehicle, object, non-motorist in road)
    --  12  = Over-Correcting / Over-Steering
    --  13  = Failure to Yield Right-of-Way
    --  14  = Failure to Obey Traffic Signs, Signals, or Officer
    --  15  = Wrong Side or Wrong Way
    --  16  = Made Improper Entry to / Exit from Trafficway
    --  17  = Operated Without Required Equipment
    --  98  = Other Improper Action
    --  99  = Unknown
    PDA_DRIVER_ACTION_CODE          NUMBER(3)       NOT NULL,

    -- Audit columns
    PDA_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    PDA_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    PDA_MODIFIED_BY                 VARCHAR2(100),
    PDA_MODIFIED_DT                 DATE,
    PDA_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_PDA_PRS_SEQ UNIQUE (PDA_PERSON_ID, PDA_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE PERSON_DRIVER_ACTION_TBL IS
    'MMUCC P14 - Driver Actions/Circumstances Contributing to Crash. Stores up to 4 driver action codes per driver involved in a crash.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_PERSON_ID IS
    'Foreign key to PERSON_TBL. The driver person for whom this action is recorded.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through PERSON_TBL.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_SEQUENCE_NUM IS
    'Sequence of this driver action record for the person. Valid range: 1-4.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_DRIVER_ACTION_CODE IS
    'MMUCC P14 Driver Actions/Circumstances code. 0=No Improper Action; 1=Improper Turn; 2=Improper Lane Change; 3=Improper Backing; 4=Improper Passing; 5=Following Too Closely; 6=Ran Off Road; 7=Ran Stop Sign; 8=Ran Red Light; 9=Exceeded Speed Limit; 10=Operating Vehicle Erratically; 11=Swerved or Avoided; 12=Over-Correcting/Over-Steering; 13=Failure to Yield Right-of-Way; 14=Failure to Obey Traffic Signs/Signals/Officer; 15=Wrong Side or Wrong Way; 16=Made Improper Entry to/Exit from Trafficway; 17=Operated Without Required Equipment; 98=Other Improper Action; 99=Unknown.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN PERSON_DRIVER_ACTION_TBL.PDA_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_PDA_PERSON_ID ON PERSON_DRIVER_ACTION_TBL (PDA_PERSON_ID);

CREATE INDEX IDX_PDA_CRASH_ID  ON PERSON_DRIVER_ACTION_TBL (PDA_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE PERSON_DRIVER_ACTION_TBL
    ADD CONSTRAINT FK_PDA_PERSON
        FOREIGN KEY (PDA_PERSON_ID)
        REFERENCES PERSON_TBL (PRS_ID)
        ON DELETE CASCADE;

ALTER TABLE PERSON_DRIVER_ACTION_TBL
    ADD CONSTRAINT FK_PDA_CRASH
        FOREIGN KEY (PDA_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
