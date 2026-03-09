-- =============================================================================
-- FILE: 03_CRASH_TBL.sql
-- DESC: MMUCC v5 Crash table (Oracle 19c translation of MySQL CRASH_TBL).
--       One row per crash report. Covers MMUCC crash-level data elements C2–C27.
-- DB:   Oracle 19c
-- =============================================================================

CREATE TABLE CRASH_TBL (
    CRS_CRASH_ID                    NUMBER          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_CRS PRIMARY KEY,
    CRS_CRASH_IDENTIFIER            VARCHAR2(50),
    CRS_CRASH_TYPE_CODE             NUMBER(3),
    CRS_FIRST_HARMFUL_EVENT_CODE    NUMBER(3),
    CRS_CRASH_DATE                  DATE,
    CRS_CRASH_TIME                  VARCHAR2(5),
    CRS_COUNTY_FIPS_CODE            VARCHAR2(10),
    CRS_COUNTY_NAME                 VARCHAR2(100),
    CRS_CITY_PLACE_CODE             VARCHAR2(10),
    CRS_CITY_PLACE_NAME             VARCHAR2(100),
    CRS_ROUTE_ID                    VARCHAR2(50),
    CRS_ROUTE_TYPE_CODE             NUMBER(3),
    CRS_ROUTE_DIRECTION_CODE        NUMBER(3),
    CRS_DISTANCE_FROM_REF_MILES     NUMBER(8,3),
    CRS_REF_POINT_DIRECTION_CODE    NUMBER(3),
    CRS_LATITUDE                    NUMBER(10,7),
    CRS_LONGITUDE                   NUMBER(10,7),
    CRS_LOC_FIRST_HARMFUL_EVENT     NUMBER(3),
    CRS_MANNER_COLLISION_CODE       NUMBER(3),
    CRS_SOURCE_OF_INFO_CODE         NUMBER(3),
    CRS_LIGHT_CONDITION_CODE        NUMBER(3),
    CRS_JUNCTION_INTERCHANGE_FLG    NUMBER(3),
    CRS_JUNCTION_LOCATION_CODE      NUMBER(3),
    CRS_INTERSECTION_APPROACHES     NUMBER(3),
    CRS_INTERSECTION_GEOMETRY_CODE  NUMBER(3),
    CRS_INTERSECTION_TRAFFIC_CTL    NUMBER(3),
    CRS_SCHOOL_BUS_RELATED_CODE     NUMBER(3),
    CRS_WORK_ZONE_RELATED_CODE      NUMBER(3),
    CRS_WORK_ZONE_LOCATION_CODE     NUMBER(3),
    CRS_WORK_ZONE_TYPE_CODE         NUMBER(3),
    CRS_WORK_ZONE_WORKERS_CODE      NUMBER(3),
    CRS_WORK_ZONE_LAW_ENF_CODE      NUMBER(3),
    CRS_CRASH_SEVERITY_CODE         NUMBER(3),
    CRS_NUM_MOTOR_VEHICLES          NUMBER(5),
    CRS_NUM_MOTORISTS               NUMBER(5),
    CRS_NUM_NON_MOTORISTS           NUMBER(5),
    CRS_NUM_NON_FATALLY_INJURED     NUMBER(5),
    CRS_NUM_FATALITIES              NUMBER(5),
    CRS_ALCOHOL_INVOLVEMENT_CODE    NUMBER(3),
    CRS_DRUG_INVOLVEMENT_CODE       NUMBER(3),
    CRS_DAY_OF_WEEK_CODE            NUMBER(3),
    CRS_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    CRS_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    CRS_MODIFIED_BY                 VARCHAR2(100),
    CRS_MODIFIED_DT                 DATE,
    CRS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL
);

-- ---------------------------------------------------------------------------
-- Table comment
-- ---------------------------------------------------------------------------
COMMENT ON TABLE CRASH_TBL IS
    'MMUCC v5 crash-level data. One row per crash report. Covers data elements C2 through C27 including crash classification, location, roadway characteristics, junction/work zone attributes, and crash summary counts.';

-- ---------------------------------------------------------------------------
-- Column comments
-- ---------------------------------------------------------------------------
COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_ID IS
    'Surrogate primary key, system-generated identity column.';

COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_IDENTIFIER IS
    'Agency-assigned crash report number or external identifier. Not necessarily unique across agencies.';

COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_TYPE_CODE IS
    'MMUCC C2 SF1: Crash Classification - Crash Type. FK to LOOKUP_CODE_VALUES_TBL (TYPE_CODE=CRASH_TYPE).';

COMMENT ON COLUMN CRASH_TBL.CRS_FIRST_HARMFUL_EVENT_CODE IS
    'MMUCC C2 SF2 / C7: First Harmful Event. FK to LOOKUP_CODE_VALUES_TBL (TYPE_CODE=HARMFUL_EVENT).';

COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_DATE IS
    'MMUCC C3 SF1: Date of crash. Oracle DATE type; time component should be set to midnight (00:00:00) when storing date only.';

COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_TIME IS
    'MMUCC C3 SF2: Time of crash in HH:MM (24-hour) format.';

COMMENT ON COLUMN CRASH_TBL.CRS_COUNTY_FIPS_CODE IS
    'MMUCC C4 SF1: County FIPS code where crash occurred.';

COMMENT ON COLUMN CRASH_TBL.CRS_COUNTY_NAME IS
    'MMUCC C4 SF2: County name where crash occurred.';

COMMENT ON COLUMN CRASH_TBL.CRS_CITY_PLACE_CODE IS
    'MMUCC C5 SF1: Census place code (city/town/CDP) where crash occurred.';

COMMENT ON COLUMN CRASH_TBL.CRS_CITY_PLACE_NAME IS
    'MMUCC C5 SF2: City or place name where crash occurred.';

COMMENT ON COLUMN CRASH_TBL.CRS_ROUTE_ID IS
    'MMUCC C6 SF1: Route identifier or linear referencing system ID.';

COMMENT ON COLUMN CRASH_TBL.CRS_ROUTE_TYPE_CODE IS
    'MMUCC C6 SF2: Route type (Interstate, US Route, State Route, etc.).';

COMMENT ON COLUMN CRASH_TBL.CRS_ROUTE_DIRECTION_CODE IS
    'MMUCC C6 SF3: Direction of route travel.';

COMMENT ON COLUMN CRASH_TBL.CRS_DISTANCE_FROM_REF_MILES IS
    'MMUCC C6 SF4: Distance from reference point in miles (up to 3 decimal places).';

COMMENT ON COLUMN CRASH_TBL.CRS_REF_POINT_DIRECTION_CODE IS
    'MMUCC C6 SF5: Direction from reference point to crash location.';

COMMENT ON COLUMN CRASH_TBL.CRS_LATITUDE IS
    'MMUCC C6 Optional: GPS latitude of crash location in decimal degrees (7 decimal places).';

COMMENT ON COLUMN CRASH_TBL.CRS_LONGITUDE IS
    'MMUCC C6 Optional: GPS longitude of crash location in decimal degrees (7 decimal places).';

COMMENT ON COLUMN CRASH_TBL.CRS_LOC_FIRST_HARMFUL_EVENT IS
    'MMUCC C8: Location of first harmful event relative to roadway.';

COMMENT ON COLUMN CRASH_TBL.CRS_MANNER_COLLISION_CODE IS
    'MMUCC C9: Manner of collision (e.g., angle, rear-end, head-on).';

COMMENT ON COLUMN CRASH_TBL.CRS_SOURCE_OF_INFO_CODE IS
    'MMUCC C10: Source of information used to complete the crash report.';

COMMENT ON COLUMN CRASH_TBL.CRS_LIGHT_CONDITION_CODE IS
    'MMUCC C12: Light condition at time of crash (daylight, dark, dusk, etc.).';

COMMENT ON COLUMN CRASH_TBL.CRS_JUNCTION_INTERCHANGE_FLG IS
    'MMUCC C15 SF1: Flag indicating whether crash occurred within a junction or interchange area.';

COMMENT ON COLUMN CRASH_TBL.CRS_JUNCTION_LOCATION_CODE IS
    'MMUCC C15 SF2: Specific junction or interchange location type.';

COMMENT ON COLUMN CRASH_TBL.CRS_INTERSECTION_APPROACHES IS
    'MMUCC C16 SF1: Number of approaches at the intersection.';

COMMENT ON COLUMN CRASH_TBL.CRS_INTERSECTION_GEOMETRY_CODE IS
    'MMUCC C16 SF2: Intersection geometry type (T-intersection, Y-intersection, 4-way, etc.).';

COMMENT ON COLUMN CRASH_TBL.CRS_INTERSECTION_TRAFFIC_CTL IS
    'MMUCC C16 SF3: Traffic control device at the intersection.';

COMMENT ON COLUMN CRASH_TBL.CRS_SCHOOL_BUS_RELATED_CODE IS
    'MMUCC C17: Whether a school bus was involved in or related to the crash.';

COMMENT ON COLUMN CRASH_TBL.CRS_WORK_ZONE_RELATED_CODE IS
    'MMUCC C18 SF1: Whether the crash occurred in or was related to a work zone.';

COMMENT ON COLUMN CRASH_TBL.CRS_WORK_ZONE_LOCATION_CODE IS
    'MMUCC C18 SF2: Location of the work zone (e.g., before, within, transition).';

COMMENT ON COLUMN CRASH_TBL.CRS_WORK_ZONE_TYPE_CODE IS
    'MMUCC C18 SF3: Type of work zone.';

COMMENT ON COLUMN CRASH_TBL.CRS_WORK_ZONE_WORKERS_CODE IS
    'MMUCC C18 SF4: Whether workers were present in the work zone.';

COMMENT ON COLUMN CRASH_TBL.CRS_WORK_ZONE_LAW_ENF_CODE IS
    'MMUCC C18 SF5: Whether law enforcement was present in the work zone.';

COMMENT ON COLUMN CRASH_TBL.CRS_CRASH_SEVERITY_CODE IS
    'MMUCC C19: Overall crash severity (derived as highest KABCO injury status among all persons involved).';

COMMENT ON COLUMN CRASH_TBL.CRS_NUM_MOTOR_VEHICLES IS
    'MMUCC C20: Total number of motor vehicles involved in the crash.';

COMMENT ON COLUMN CRASH_TBL.CRS_NUM_MOTORISTS IS
    'MMUCC C21: Total number of motorists (drivers and passengers in motor vehicles) involved.';

COMMENT ON COLUMN CRASH_TBL.CRS_NUM_NON_MOTORISTS IS
    'MMUCC C22: Total number of non-motorists (pedestrians, cyclists, etc.) involved.';

COMMENT ON COLUMN CRASH_TBL.CRS_NUM_NON_FATALLY_INJURED IS
    'MMUCC C23: Total number of persons with non-fatal injuries (KABCO A, B, or C).';

COMMENT ON COLUMN CRASH_TBL.CRS_NUM_FATALITIES IS
    'MMUCC C24: Total number of fatalities (KABCO K) resulting from the crash.';

COMMENT ON COLUMN CRASH_TBL.CRS_ALCOHOL_INVOLVEMENT_CODE IS
    'MMUCC C25: Whether alcohol involvement was indicated for any person in the crash.';

COMMENT ON COLUMN CRASH_TBL.CRS_DRUG_INVOLVEMENT_CODE IS
    'MMUCC C26: Whether drug involvement was indicated for any person in the crash.';

COMMENT ON COLUMN CRASH_TBL.CRS_DAY_OF_WEEK_CODE IS
    'MMUCC C27: Day of week the crash occurred (1=Sunday through 7=Saturday).';

COMMENT ON COLUMN CRASH_TBL.CRS_CREATED_BY IS
    'Username or process that created this row.';

COMMENT ON COLUMN CRASH_TBL.CRS_CREATED_DT IS
    'Date and time this row was created. Defaults to SYSDATE.';

COMMENT ON COLUMN CRASH_TBL.CRS_MODIFIED_BY IS
    'Username or process that last modified this row. NULL if never modified.';

COMMENT ON COLUMN CRASH_TBL.CRS_MODIFIED_DT IS
    'Date and time this row was last modified. NULL if never modified.';

COMMENT ON COLUMN CRASH_TBL.CRS_LAST_UPDATED_ACTIVITY_CODE IS
    'Code identifying the activity (e.g., IMPORT, USER_EDIT) that last updated this row.';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------
CREATE INDEX IDX_CRS_CRASH_IDENTIFIER ON CRASH_TBL (CRS_CRASH_IDENTIFIER);

CREATE INDEX IDX_CRS_CRASH_DATE ON CRASH_TBL (CRS_CRASH_DATE);

CREATE INDEX IDX_CRS_SEVERITY ON CRASH_TBL (CRS_CRASH_SEVERITY_CODE);

CREATE INDEX IDX_CRS_COUNTY ON CRASH_TBL (CRS_COUNTY_FIPS_CODE);

CREATE INDEX IDX_CRS_CITY ON CRASH_TBL (CRS_CITY_PLACE_CODE);

CREATE INDEX IDX_CRS_LOCATION ON CRASH_TBL (CRS_LATITUDE, CRS_LONGITUDE);
