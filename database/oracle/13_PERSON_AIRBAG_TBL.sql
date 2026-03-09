-- =============================================================================
-- FILE:    13_PERSON_AIRBAG_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   PERSON_AIRBAG_TBL (PAB)
-- PURPOSE: MMUCC P9 - Air Bag Deployed. Up to 4 airbag deployment records
--          per person.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE PERSON_AIRBAG_TBL (

    PAB_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_PAB PRIMARY KEY,

    PAB_PERSON_ID                   NUMBER(10)      NOT NULL,
    PAB_CRASH_ID                    NUMBER(10)      NOT NULL,
    PAB_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- P9 Air Bag Deployed code:
    --   0  = Not Deployed
    --   1  = Deployed - Front
    --   2  = Deployed - Side (door, door/window, seat/cushion)
    --   3  = Deployed - Other (knee, airbelt, etc.)
    --   4  = Deployed - Combination
    --   5  = Deployed - Unknown Location
    --   7  = Deployed - Curtain
    --  97  = Not Applicable (no airbag present in vehicle/seating position)
    --  98  = Unknown if Deployed
    PAB_AIRBAG_DEPLOYED_CODE        NUMBER(3)       NOT NULL,

    -- Audit columns
    PAB_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    PAB_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    PAB_MODIFIED_BY                 VARCHAR2(100),
    PAB_MODIFIED_DT                 DATE,
    PAB_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_PAB_PRS_SEQ UNIQUE (PAB_PERSON_ID, PAB_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE PERSON_AIRBAG_TBL IS
    'MMUCC P9 - Air Bag Deployed. Stores up to 4 airbag deployment outcome codes per person involved in a crash.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_PERSON_ID IS
    'Foreign key to PERSON_TBL. The person for whom this airbag deployment is recorded.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through PERSON_TBL.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_SEQUENCE_NUM IS
    'Sequence of this airbag record for the person. Valid range: 1-4.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_AIRBAG_DEPLOYED_CODE IS
    'MMUCC P9 Air Bag Deployed code. 0=Not Deployed; 1=Deployed-Front; 2=Deployed-Side (door, door/window, seat/cushion); 3=Deployed-Other (knee, airbelt, etc.); 4=Deployed-Combination; 5=Deployed-Unknown Location; 7=Deployed-Curtain; 97=Not Applicable (no airbag present); 98=Unknown if Deployed.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN PERSON_AIRBAG_TBL.PAB_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_PAB_PERSON_ID ON PERSON_AIRBAG_TBL (PAB_PERSON_ID);

CREATE INDEX IDX_PAB_CRASH_ID  ON PERSON_AIRBAG_TBL (PAB_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE PERSON_AIRBAG_TBL
    ADD CONSTRAINT FK_PAB_PERSON
        FOREIGN KEY (PAB_PERSON_ID)
        REFERENCES PERSON_TBL (PRS_ID)
        ON DELETE CASCADE;

ALTER TABLE PERSON_AIRBAG_TBL
    ADD CONSTRAINT FK_PAB_CRASH
        FOREIGN KEY (PAB_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
