-- =============================================================================
-- FILE:    11_VEHICLE_DAMAGE_AREA_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   VEHICLE_DAMAGE_AREA_TBL (VDA)
-- PURPOSE: MMUCC V19 SF2 - Damaged Areas. Up to 13 clock-position damage
--          areas recorded per vehicle.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE VEHICLE_DAMAGE_AREA_TBL (

    VDA_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_VDA PRIMARY KEY,

    VDA_VEHICLE_ID                  NUMBER(10)      NOT NULL,
    VDA_CRASH_ID                    NUMBER(10)      NOT NULL,
    VDA_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- V19 SF2 Damaged Area:
    --   0  = Non-Collision (Entire Vehicle)
    --   1  = 12-1 o'clock  (right-front corner)
    --   2  = 1-2 o'clock
    --   3  = 2-3 o'clock   (right side front)
    --   4  = 3-4 o'clock   (right side)
    --   5  = 4-5 o'clock   (right side rear)
    --   6  = 5-6 o'clock   (right-rear corner)
    --   7  = 6-7 o'clock   (rear center)
    --   8  = 7-8 o'clock   (left-rear corner)
    --   9  = 8-9 o'clock   (left side rear)
    --  10  = 9-10 o'clock  (left side)
    --  11  = 10-11 o'clock (left side front)
    --  12  = 11-12 o'clock (left-front corner)
    --  13  = Top
    --  14  = Undercarriage
    --  15  = Cargo Loss
    --  99  = Unknown
    VDA_DAMAGE_AREA_CODE            NUMBER(3)       NOT NULL,

    -- Audit columns
    VDA_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    VDA_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    VDA_MODIFIED_BY                 VARCHAR2(100),
    VDA_MODIFIED_DT                 DATE,
    VDA_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_VDA_VEH_SEQ UNIQUE (VDA_VEHICLE_ID, VDA_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE VEHICLE_DAMAGE_AREA_TBL IS
    'MMUCC V19 SF2 - Damaged Areas. Stores up to 13 clock-position damage area codes per vehicle. Each row represents one damaged area on the vehicle involved in the crash.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_VEHICLE_ID IS
    'Foreign key to VEHICLE_TBL. The vehicle on which this damage area was recorded.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through VEHICLE_TBL.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_SEQUENCE_NUM IS
    'Chronological or priority sequence of the damage area record for the vehicle. Valid range: 1-13.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_DAMAGE_AREA_CODE IS
    'MMUCC V19 SF2 Damaged Area code. 0=Non-Collision (Entire Vehicle); 1-12=Clock position (1=12-1 o''clock through 12=11-12 o''clock); 13=Top; 14=Undercarriage; 15=Cargo Loss; 99=Unknown.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN VEHICLE_DAMAGE_AREA_TBL.VDA_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_VDA_VEHICLE_ID ON VEHICLE_DAMAGE_AREA_TBL (VDA_VEHICLE_ID);

CREATE INDEX IDX_VDA_CRASH_ID   ON VEHICLE_DAMAGE_AREA_TBL (VDA_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE VEHICLE_DAMAGE_AREA_TBL
    ADD CONSTRAINT FK_VDA_VEHICLE
        FOREIGN KEY (VDA_VEHICLE_ID)
        REFERENCES VEHICLE_TBL (VEH_ID)
        ON DELETE CASCADE;

ALTER TABLE VEHICLE_DAMAGE_AREA_TBL
    ADD CONSTRAINT FK_VDA_CRASH
        FOREIGN KEY (VDA_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
