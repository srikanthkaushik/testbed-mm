-- =============================================================================
-- FILE:    15_PERSON_DL_RESTRICTION_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   PERSON_DL_RESTRICTION_TBL (PDR)
-- PURPOSE: MMUCC P16 SF1 - Driver License Restrictions. Up to 3 restriction
--          codes recorded per driver.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE PERSON_DL_RESTRICTION_TBL (

    PDR_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_PDR PRIMARY KEY,

    PDR_PERSON_ID                   NUMBER(10)      NOT NULL,
    PDR_CRASH_ID                    NUMBER(10)      NOT NULL,
    PDR_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- P16 SF1 Driver License Restriction code:
    --   0  = None
    --   1  = Corrective Lenses
    --   2  = Mechanical Devices (power steering, hand controls, etc.)
    --   3  = Prosthetic Aid
    --   4  = Automatic Transmission
    --   5  = Outside Mirror
    --   6  = Limit to Daylight Only
    --   7  = Limit to Employment (drive to/from work only)
    --   8  = Limit to Area (within X miles of home)
    --   9  = Military Only
    --  10  = No CDL Needed - Personal Vehicle Only
    --  11  = No Passengers
    --  12  = Speed Restrictions
    --  13  = Must Drive with Another Licensed Driver
    --  97  = Not Applicable
    --  98  = Other
    --  99  = Unknown
    PDR_RESTRICTION_CODE            NUMBER(3)       NOT NULL,

    -- Audit columns
    PDR_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    PDR_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    PDR_MODIFIED_BY                 VARCHAR2(100),
    PDR_MODIFIED_DT                 DATE,
    PDR_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_PDR_PRS_SEQ UNIQUE (PDR_PERSON_ID, PDR_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE PERSON_DL_RESTRICTION_TBL IS
    'MMUCC P16 SF1 - Driver License Restrictions. Stores up to 3 driver license restriction codes per driver involved in a crash.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_PERSON_ID IS
    'Foreign key to PERSON_TBL. The driver person whose license restriction is recorded.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through PERSON_TBL.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_SEQUENCE_NUM IS
    'Sequence of this restriction record for the person. Valid range: 1-3.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_RESTRICTION_CODE IS
    'MMUCC P16 SF1 Driver License Restriction code. 0=None; 1=Corrective Lenses; 2=Mechanical Devices; 3=Prosthetic Aid; 4=Automatic Transmission; 5=Outside Mirror; 6=Limit to Daylight Only; 7=Limit to Employment; 8=Limit to Area; 9=Military Only; 10=No CDL Needed-Personal Vehicle Only; 11=No Passengers; 12=Speed Restrictions; 13=Must Drive with Another Licensed Driver; 97=Not Applicable; 98=Other; 99=Unknown.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN PERSON_DL_RESTRICTION_TBL.PDR_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_PDR_PERSON_ID ON PERSON_DL_RESTRICTION_TBL (PDR_PERSON_ID);

CREATE INDEX IDX_PDR_CRASH_ID  ON PERSON_DL_RESTRICTION_TBL (PDR_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE PERSON_DL_RESTRICTION_TBL
    ADD CONSTRAINT FK_PDR_PERSON
        FOREIGN KEY (PDR_PERSON_ID)
        REFERENCES PERSON_TBL (PRS_ID)
        ON DELETE CASCADE;

ALTER TABLE PERSON_DL_RESTRICTION_TBL
    ADD CONSTRAINT FK_PDR_CRASH
        FOREIGN KEY (PDR_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
