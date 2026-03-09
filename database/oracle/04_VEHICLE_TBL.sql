-- =============================================================================
-- FILE: 04_VEHICLE_TBL.sql
-- DESC: MMUCC v5 Vehicle table (Oracle 19c translation of MySQL VEHICLE_TBL).
--       One row per vehicle unit involved in a crash.
--       Covers MMUCC vehicle-level data elements V1–V22.
-- DB:   Oracle 19c
-- =============================================================================

CREATE TABLE VEHICLE_TBL (
    VEH_VEHICLE_ID                  NUMBER          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_VEH PRIMARY KEY,
    VEH_CRASH_ID                    NUMBER(10)      NOT NULL,
    VEH_VIN                         VARCHAR2(17),
    VEH_UNIT_TYPE_CODE              NUMBER(3),
    VEH_UNIT_NUMBER                 NUMBER(3),
    VEH_REGISTRATION_STATE          VARCHAR2(10),
    VEH_REGISTRATION_YEAR           NUMBER(4),
    VEH_LICENSE_PLATE               VARCHAR2(20),
    VEH_MAKE                        VARCHAR2(50),
    VEH_MODEL_YEAR                  NUMBER(4),
    VEH_MODEL                       VARCHAR2(50),
    VEH_BODY_TYPE_CODE              NUMBER(3),
    VEH_TRAILING_UNITS_COUNT        NUMBER(3),
    VEH_VEHICLE_SIZE_CODE           NUMBER(3),
    VEH_HM_PLACARD_FLG              NUMBER(3),
    VEH_TOTAL_OCCUPANTS             NUMBER(3),
    VEH_SPECIAL_FUNCTION_CODE       NUMBER(3),
    VEH_EMERGENCY_USE_CODE          NUMBER(3),
    VEH_SPEED_LIMIT_MPH             NUMBER(3),
    VEH_DIRECTION_OF_TRAVEL_CODE    NUMBER(3),
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE  NUMBER(3),
    VEH_TRAFFICWAY_DIVIDED_CODE     NUMBER(3),
    VEH_TRAFFICWAY_BARRIER_CODE     NUMBER(3),
    VEH_TRAFFICWAY_HOV_HOT_CODE     NUMBER(3),
    VEH_TRAFFICWAY_HOV_CRASH_FLG    NUMBER(3),
    VEH_TOTAL_THROUGH_LANES         NUMBER(3),
    VEH_TOTAL_AUXILIARY_LANES       NUMBER(3),
    VEH_ROADWAY_ALIGNMENT_CODE      NUMBER(3),
    VEH_ROADWAY_GRADE_CODE          NUMBER(3),
    VEH_MANEUVER_CODE               NUMBER(3),
    VEH_DAMAGE_INITIAL_CONTACT      NUMBER(3),
    VEH_DAMAGE_EXTENT_CODE          NUMBER(3),
    VEH_MOST_HARMFUL_EVENT_CODE     NUMBER(3),
    VEH_HIT_AND_RUN_CODE            NUMBER(3),
    VEH_TOWED_CODE                  NUMBER(3),
    VEH_CONTRIBUTING_CIRC_CODE      NUMBER(3),
    VEH_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    VEH_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    VEH_MODIFIED_BY                 VARCHAR2(100),
    VEH_MODIFIED_DT                 DATE,
    VEH_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL
);

-- ---------------------------------------------------------------------------
-- Table comment
-- ---------------------------------------------------------------------------
COMMENT ON TABLE VEHICLE_TBL IS
    'MMUCC v5 vehicle-level data. One row per vehicle unit involved in a crash. Child of CRASH_TBL. Covers data elements V1 through V22 including vehicle identification, registration, body type, trafficway characteristics, maneuver, damage, and contributing circumstances.';

-- ---------------------------------------------------------------------------
-- Column comments
-- ---------------------------------------------------------------------------
COMMENT ON COLUMN VEHICLE_TBL.VEH_VEHICLE_ID IS
    'Surrogate primary key, system-generated identity column.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_CRASH_ID IS
    'Foreign key to CRASH_TBL.CRS_CRASH_ID. Identifies the crash this vehicle was involved in.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_VIN IS
    'MMUCC V1: Vehicle Identification Number (17-character standard VIN).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_UNIT_TYPE_CODE IS
    'MMUCC V2: Unit type (motor vehicle in transport, parked, non-motor vehicle, etc.).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_UNIT_NUMBER IS
    'Sequential unit number within the crash (1, 2, 3, ...). Combined with VEH_CRASH_ID uniquely identifies a vehicle within a crash.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_REGISTRATION_STATE IS
    'MMUCC V3 SF1: State or jurisdiction where the vehicle is registered (2-letter FIPS code or state abbreviation).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_REGISTRATION_YEAR IS
    'MMUCC V3 SF2: Year of vehicle registration.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_LICENSE_PLATE IS
    'MMUCC V3 SF3: Vehicle license plate number.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MAKE IS
    'MMUCC V4 SF1: Vehicle manufacturer make (e.g., FORD, TOYOTA, CHEVROLET).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MODEL_YEAR IS
    'MMUCC V4 SF2: Model year of the vehicle.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MODEL IS
    'MMUCC V4 SF3: Vehicle model name or designation.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_BODY_TYPE_CODE IS
    'MMUCC V8 SF1: Motor vehicle body type. FK to LOOKUP_CODE_VALUES_TBL (TYPE_CODE=BODY_TYPE). Determines whether Large Vehicle section is required.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAILING_UNITS_COUNT IS
    'MMUCC V9: Number of trailing units (trailers) attached to this vehicle.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_VEHICLE_SIZE_CODE IS
    'MMUCC V10: Vehicle size/weight category as defined by MMUCC.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_HM_PLACARD_FLG IS
    'MMUCC V11: Hazardous materials placard flag (1=Yes, 0=No, 9=Unknown).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TOTAL_OCCUPANTS IS
    'MMUCC V12: Total number of occupants in this vehicle at the time of the crash.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_SPECIAL_FUNCTION_CODE IS
    'MMUCC V13: Special function of the motor vehicle (e.g., taxi, military, farm, school bus).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_EMERGENCY_USE_CODE IS
    'MMUCC V14: Whether the vehicle was in emergency use at the time of the crash.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_SPEED_LIMIT_MPH IS
    'MMUCC V15: Posted speed limit in miles per hour on the roadway where the crash occurred.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_DIRECTION_OF_TRAVEL_CODE IS
    'MMUCC V16: Direction of travel of this vehicle immediately prior to the crash.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAFFICWAY_TRAVEL_DIR_CODE IS
    'MMUCC V17 SF1: Trafficway flow direction (one-way, two-way, etc.).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAFFICWAY_DIVIDED_CODE IS
    'MMUCC V17 SF2: Whether the trafficway is divided (with median or barrier).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAFFICWAY_BARRIER_CODE IS
    'MMUCC V17 SF3: Type of median barrier present on the trafficway.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAFFICWAY_HOV_HOT_CODE IS
    'MMUCC V17 SF4: Whether the trafficway includes an HOV or HOT lane.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TRAFFICWAY_HOV_CRASH_FLG IS
    'MMUCC V17 SF5: Whether the crash occurred in the HOV/HOT lane.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TOTAL_THROUGH_LANES IS
    'MMUCC V18 SF1: Total number of through lanes on the roadway at the crash location.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TOTAL_AUXILIARY_LANES IS
    'MMUCC V18 SF2: Total number of auxiliary lanes (turn lanes, acceleration/deceleration lanes) at the crash location.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_ROADWAY_ALIGNMENT_CODE IS
    'MMUCC V19 SF1: Horizontal alignment of the roadway at the crash location (straight, curve).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_ROADWAY_GRADE_CODE IS
    'MMUCC V19 SF2: Vertical grade of the roadway at the crash location (level, hillcrest, grade, sag).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MANEUVER_CODE IS
    'MMUCC V22: Pre-crash maneuver or action of the vehicle prior to the crash.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_DAMAGE_INITIAL_CONTACT IS
    'MMUCC V23 SF1: Area of initial contact/impact on the vehicle using clock-position coding.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_DAMAGE_EXTENT_CODE IS
    'MMUCC V23 SF2: Extent of damage to the vehicle (none, minor, functional, disabling, demolished).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MOST_HARMFUL_EVENT_CODE IS
    'MMUCC V20: Most harmful event for this vehicle. FK to LOOKUP_CODE_VALUES_TBL (TYPE_CODE=HARMFUL_EVENT).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_HIT_AND_RUN_CODE IS
    'MMUCC V24: Whether this vehicle was involved in a hit-and-run (driver fled the scene).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_TOWED_CODE IS
    'MMUCC V25: Whether and how this vehicle was towed from the crash scene.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_CONTRIBUTING_CIRC_CODE IS
    'MMUCC V26: Vehicle-related contributing circumstance (defect or condition that may have contributed to the crash).';

COMMENT ON COLUMN VEHICLE_TBL.VEH_CREATED_BY IS
    'Username or process that created this row.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_CREATED_DT IS
    'Date and time this row was created. Defaults to SYSDATE.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MODIFIED_BY IS
    'Username or process that last modified this row. NULL if never modified.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_MODIFIED_DT IS
    'Date and time this row was last modified. NULL if never modified.';

COMMENT ON COLUMN VEHICLE_TBL.VEH_LAST_UPDATED_ACTIVITY_CODE IS
    'Code identifying the activity (e.g., IMPORT, USER_EDIT) that last updated this row.';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IDX_VEH_CRASH_ID ON VEHICLE_TBL (VEH_CRASH_ID);

CREATE INDEX IDX_VEH_UNIT ON VEHICLE_TBL (VEH_CRASH_ID, VEH_UNIT_NUMBER);

CREATE INDEX IDX_VEH_VIN ON VEHICLE_TBL (VEH_VIN);

CREATE INDEX IDX_VEH_BODY_TYPE ON VEHICLE_TBL (VEH_BODY_TYPE_CODE);

-- ---------------------------------------------------------------------------
-- Foreign key
-- ---------------------------------------------------------------------------
ALTER TABLE VEHICLE_TBL
    ADD CONSTRAINT FK_VEH_CRASH
    FOREIGN KEY (VEH_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
