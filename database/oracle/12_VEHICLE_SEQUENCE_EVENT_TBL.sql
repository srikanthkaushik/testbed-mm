-- =============================================================================
-- FILE:    12_VEHICLE_SEQUENCE_EVENT_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   VEHICLE_SEQUENCE_EVENT_TBL (VSE)
-- PURPOSE: MMUCC V20 - Sequence of Events. Up to 4 chronological events
--          recorded per vehicle.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE VEHICLE_SEQUENCE_EVENT_TBL (

    VSE_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_VSE PRIMARY KEY,

    VSE_VEHICLE_ID                  NUMBER(10)      NOT NULL,
    VSE_CRASH_ID                    NUMBER(10)      NOT NULL,
    VSE_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- V20 Sequence of Events / Harmful Event code.
    -- FK to LOOKUP_CODE_VALUES (type HARMFUL_EVENT).
    -- Selected MMUCC values (1-51, 99):
    --   1  = Ran Off Road - Right
    --   2  = Ran Off Road - Left
    --   3  = Cross Median / Centerline
    --   4  = Downhill Runaway
    --   5  = Cargo / Equipment Loss or Shift
    --   6  = Separation of Units
    --   7  = Fire / Explosion
    --   8  = Immersion (partial or total)
    --   9  = Jackknife
    --  10  = Fell / Jumped from Vehicle
    --  11  = Thrown or Falling Object
    --  12  = Other Non-Collision
    --  13  = Pedestrian
    --  14  = Pedalcyclist
    --  15  = Railway Vehicle
    --  16  = Animal
    --  17  = Motor Vehicle in Transport
    --  18  = Parked Motor Vehicle
    --  19  = Work Zone Maintenance Equipment
    --  20  = Struck By Falling / Shifting Cargo
    --  21  = Other Non-Fixed Object
    --  22  = Impact Attenuator / Crash Cushion
    --  23  = Bridge Overhead Structure
    --  24  = Bridge Pier or Support
    --  25  = Bridge Rail
    --  26  = Culvert
    --  27  = Curb
    --  28  = Ditch
    --  29  = Embankment
    --  30  = Guardrail Face
    --  31  = Guardrail End
    --  32  = Cable Barrier
    --  33  = Concrete Traffic Barrier
    --  34  = Other Traffic Barrier
    --  35  = Tree (Standing)
    --  36  = Utility Pole / Light Support
    --  37  = Traffic Sign Support
    --  38  = Traffic Signal Support
    --  39  = Other Post, Pole, or Support
    --  40  = Fence
    --  41  = Mailbox
    --  42  = Other Fixed Object
    --  43  = Building
    --  44  = Wall
    --  45  = Fire Hydrant
    --  46  = Shrubbery
    --  47  = Unknown Fixed Object
    --  48  = Pavement Surface Irregularity
    --  49  = Overhead Sign Support
    --  50  = Railing (Not Bridge)
    --  51  = Other Object
    --  99  = Unknown
    VSE_EVENT_CODE                  NUMBER(3)       NOT NULL,

    -- Audit columns
    VSE_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    VSE_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    VSE_MODIFIED_BY                 VARCHAR2(100),
    VSE_MODIFIED_DT                 DATE,
    VSE_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_VSE_VEH_SEQ UNIQUE (VSE_VEHICLE_ID, VSE_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE VEHICLE_SEQUENCE_EVENT_TBL IS
    'MMUCC V20 - Sequence of Events. Stores up to 4 chronological harmful or non-harmful events per vehicle involved in a crash. Event codes reference LOOKUP_CODE_VALUES (type HARMFUL_EVENT).';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_VEHICLE_ID IS
    'Foreign key to VEHICLE_TBL. The vehicle for which this event sequence is recorded.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through VEHICLE_TBL.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_SEQUENCE_NUM IS
    'Chronological order of this event within the vehicle''s sequence of events. Valid range: 1-4.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_EVENT_CODE IS
    'MMUCC V20 Sequence of Events / Harmful Event code. References LOOKUP_CODE_VALUES (type HARMFUL_EVENT). Values 1-51 per MMUCC event codes; 99=Unknown.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN VEHICLE_SEQUENCE_EVENT_TBL.VSE_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_VSE_VEHICLE_ID ON VEHICLE_SEQUENCE_EVENT_TBL (VSE_VEHICLE_ID);

CREATE INDEX IDX_VSE_CRASH_ID   ON VEHICLE_SEQUENCE_EVENT_TBL (VSE_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE VEHICLE_SEQUENCE_EVENT_TBL
    ADD CONSTRAINT FK_VSE_VEHICLE
        FOREIGN KEY (VSE_VEHICLE_ID)
        REFERENCES VEHICLE_TBL (VEH_ID)
        ON DELETE CASCADE;

ALTER TABLE VEHICLE_SEQUENCE_EVENT_TBL
    ADD CONSTRAINT FK_VSE_CRASH
        FOREIGN KEY (VSE_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
