-- =============================================================================
-- Table : CRASH_TBL
-- Acronym: CRS
-- Source : MMUCC v5 Crash Data Elements C1 - C27
-- Notes : Top-level entity. All other tables reference this via CRS_CRASH_ID.
--         Multi-value elements C11, C13, C14 are stored in child tables.
-- =============================================================================
CREATE TABLE CRASH_TBL (
    CRS_CRASH_ID                    INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',

    -- C1: Crash Identifier
    CRS_CRASH_IDENTIFIER            VARCHAR(50)         NULL        COMMENT 'C1: Agency-assigned unique crash number as it appears on the police report',

    -- C2: Crash Classification
    CRS_CRASH_TYPE_CODE             TINYINT UNSIGNED    NULL        COMMENT 'C2 SF1: Crash type. Values: 1=Single Vehicle, 2=Two Vehicle Same Dir, 3=Two Vehicle Opposite Dir, 4=Two Vehicle Intersecting, 5=Two Vehicle Other, 6=Three or More Vehicle, 99=Unknown',
    CRS_FIRST_HARMFUL_EVENT_CODE    TINYINT UNSIGNED    NULL        COMMENT 'C2 SF2 / C7: Code of first harmful event. FK to REF_HARMFUL_EVENT_TBL. Values: 1-51 per spec, 99=Unknown',

    -- C3: Crash Date and Time
    CRS_CRASH_DATE                  DATE                NULL        COMMENT 'C3 SF1: Date of crash (YYYY-MM-DD)',
    CRS_CRASH_TIME                  TIME                NULL        COMMENT 'C3 SF2: Time of crash (HH:MM)',

    -- C4: Crash County
    CRS_COUNTY_FIPS_CODE            VARCHAR(10)         NULL        COMMENT 'C4 SF1: FIPS county code (Appendix E of MMUCC)',
    CRS_COUNTY_NAME                 VARCHAR(100)        NULL        COMMENT 'C4 SF2: County name',

    -- C5: Crash City/Place (Political Jurisdiction)
    CRS_CITY_PLACE_CODE             VARCHAR(10)         NULL        COMMENT 'C5 SF1: FIPS place code',
    CRS_CITY_PLACE_NAME             VARCHAR(100)        NULL        COMMENT 'C5 SF2: City or place name',

    -- C6: Crash Location
    CRS_ROUTE_ID                    VARCHAR(50)         NULL        COMMENT 'C6 SF1: Route or road identifier',
    CRS_ROUTE_TYPE_CODE             TINYINT UNSIGNED    NULL        COMMENT 'C6 SF2: Route type. Values: 1=State Highway, 2=US Highway, 3=Interstate, 4=County Road, 5=City Street, 6=Other, 99=Unknown',
    CRS_ROUTE_DIRECTION_CODE        TINYINT UNSIGNED    NULL        COMMENT 'C6 SF3: Direction designator. Values: 1=NB, 2=SB, 3=EB, 4=WB, 99=Unknown',
    CRS_DISTANCE_FROM_REF_MILES     DECIMAL(8,3)        NULL        COMMENT 'C6 SF4: Distance in miles from reference point',
    CRS_REF_POINT_DIRECTION_CODE    TINYINT UNSIGNED    NULL        COMMENT 'C6 SF5: Direction from reference point. Values: 1=N, 2=S, 3=E, 4=W, 99=Unknown',
    CRS_LATITUDE                    DECIMAL(10,7)       NULL        COMMENT 'C6 Optional: GPS latitude in decimal degrees',
    CRS_LONGITUDE                   DECIMAL(10,7)       NULL        COMMENT 'C6 Optional: GPS longitude in decimal degrees',

    -- C8: Location of First Harmful Event Relative to the Trafficway
    CRS_LOC_FIRST_HARMFUL_EVENT     TINYINT UNSIGNED    NULL        COMMENT 'C8: Values: 1=On Roadway, 2=In Parking Lane or Zone, 3=Median, 4=Roadside, 5=Outside Right-of-Way, 6=Off Roadway Location Unknown, 99=Unknown',

    -- C9: Manner of Crash/Collision Impact
    CRS_MANNER_COLLISION_CODE       TINYINT UNSIGNED    NULL        COMMENT 'C9: Values: 1=Non-Collision, 2=Rear-End, 3=Head-On, 4=Rear-to-Rear, 5=Angle, 6=Sideswipe Same Direction, 7=Sideswipe Opposite Direction, 8=Other, 99=Unknown',

    -- C10: Source of Information
    CRS_SOURCE_OF_INFO_CODE         TINYINT UNSIGNED    NULL        COMMENT 'C10: Values: 1=Police Report, 2=Other Report, 3=Hospital/Medical Records, 4=Death Certificate, 98=Other, 99=Unknown',

    -- C11: Weather Conditions - multi-value (select 1-4), stored in CRASH_WEATHER_CONDITION_TBL

    -- C12: Light Condition
    CRS_LIGHT_CONDITION_CODE        TINYINT UNSIGNED    NULL        COMMENT 'C12: Values: 1=Daylight, 2=Dark-Not Lighted, 3=Dark-Lighted, 4=Dawn, 5=Dusk, 6=Dark-Unknown Lighting, 99=Unknown',

    -- C13: Roadway Surface Condition - multi-value (select 1-4), stored in CRASH_SURFACE_CONDITION_TBL

    -- C14: Contributing Circumstances Roadway - multi-value (select 1-2), stored in CRASH_CONTRIBUTING_ROADWAY_TBL

    -- C15: Relation to Junction
    CRS_JUNCTION_INTERCHANGE_FLG    TINYINT UNSIGNED    NULL        COMMENT 'C15 SF1: Within interchange area? Values: 1=No, 2=Yes, 99=Unknown',
    CRS_JUNCTION_LOCATION_CODE      TINYINT UNSIGNED    NULL        COMMENT 'C15 SF2: Specific location. Values: 0=Not Interchange, 1=Accel/Decel Lane, 2=Crossover, 3=Driveway Access, 4=Entrance/Exit Ramp, 5=Intersection or Related, 6=Non-Junction, 7=Railway Grade Crossing, 8=Shared-Use Path, 9=Through Roadway, 10=Other Within Interchange, 99=Unknown',

    -- C16: Type of Intersection
    CRS_INTERSECTION_APPROACHES     TINYINT UNSIGNED    NULL        COMMENT 'C16 SF1: Number of approaches. Values: 1=Not Intersection, 2=Two, 3=Three, 4=Four, 5=Five or More',
    CRS_INTERSECTION_GEOMETRY_CODE  TINYINT UNSIGNED    NULL        COMMENT 'C16 SF2: Overall geometry. Values: 1=Angled/Skewed, 2=Roundabout/Traffic Circle, 3=Perpendicular, 97=Not Applicable/Not Intersection',
    CRS_INTERSECTION_TRAFFIC_CTL    TINYINT UNSIGNED    NULL        COMMENT 'C16 SF3: Traffic control. Values: 1=Signalized, 2=Stop All Way, 3=Stop Partial, 4=Yield, 5=No Controls, 97=Not Applicable/Not Intersection',

    -- C17: School Bus-Related
    CRS_SCHOOL_BUS_RELATED_CODE     TINYINT UNSIGNED    NULL        COMMENT 'C17: Values: 1=No, 2=Yes School Bus Directly Involved, 3=Yes School Bus Indirectly Involved',

    -- C18: Work Zone-Related
    CRS_WORK_ZONE_RELATED_CODE      TINYINT UNSIGNED    NULL        COMMENT 'C18 SF1: In/related to work zone? Values: 1=No, 2=Yes, 99=Unknown',
    CRS_WORK_ZONE_LOCATION_CODE     TINYINT UNSIGNED    NULL        COMMENT 'C18 SF2: Values: 1=Before First Warning Sign, 2=Advance Warning Area, 3=Transition Area, 4=Activity Area, 5=Termination Area, 98=Not Applicable',
    CRS_WORK_ZONE_TYPE_CODE         TINYINT UNSIGNED    NULL        COMMENT 'C18 SF3: Values: 1=Lane Closure, 2=Lane Shift/Crossover, 3=Work on Shoulder or Median, 4=Intermittent or Moving Work, 5=Other, 98=Not Applicable',
    CRS_WORK_ZONE_WORKERS_CODE      TINYINT UNSIGNED    NULL        COMMENT 'C18 SF4: Workers present? Values: 1=No, 2=Yes, 98=Not Applicable, 99=Unknown',
    CRS_WORK_ZONE_LAW_ENF_CODE      TINYINT UNSIGNED    NULL        COMMENT 'C18 SF5: Law enforcement present? Values: 1=No, 2=Yes, 98=Not Applicable',

    -- C19: Crash Severity (derived from P5)
    CRS_CRASH_SEVERITY_CODE         TINYINT UNSIGNED    NULL        COMMENT 'C19: Most severe injury in crash. Values: 1=Fatal(K), 2=Suspected Serious(A), 3=Suspected Minor(B), 4=Possible(C), 5=Property Damage Only, 99=Unknown',

    -- C20-C24: Derived counts
    CRS_NUM_MOTOR_VEHICLES          SMALLINT UNSIGNED   NULL        COMMENT 'C20: Total count of motor vehicles involved (derived from V2)',
    CRS_NUM_MOTORISTS               SMALLINT UNSIGNED   NULL        COMMENT 'C21: Total count of motorists/occupants (derived from P4)',
    CRS_NUM_NON_MOTORISTS           SMALLINT UNSIGNED   NULL        COMMENT 'C22: Total count of non-motorists (derived from P4)',
    CRS_NUM_NON_FATALLY_INJURED     SMALLINT UNSIGNED   NULL        COMMENT 'C23: Count of persons with injury status A, B, or C (derived from P5)',
    CRS_NUM_FATALITIES              SMALLINT UNSIGNED   NULL        COMMENT 'C24: Count of fatal injuries within 30 days (derived from P5)',

    -- C25-C26: Summary involvement flags
    CRS_ALCOHOL_INVOLVEMENT_CODE    TINYINT UNSIGNED    NULL        COMMENT 'C25: Derived from P20/P21. Values: 1=No, 2=Yes, 99=Unknown',
    CRS_DRUG_INVOLVEMENT_CODE       TINYINT UNSIGNED    NULL        COMMENT 'C26: Derived from P22/P23. Values: 1=No, 2=Yes, 99=Unknown',

    -- C27: Day of Week (derived from CRS_CRASH_DATE)
    CRS_DAY_OF_WEEK_CODE            TINYINT UNSIGNED    NULL        COMMENT 'C27: Derived from crash date. Values: 1=Sunday, 2=Monday, 3=Tuesday, 4=Wednesday, 5=Thursday, 6=Friday, 7=Saturday',

    -- Audit Columns
    CRS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    CRS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    CRS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    CRS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    CRS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (CRS_CRASH_ID),
    INDEX IDX_CRS_CRASH_IDENTIFIER  (CRS_CRASH_IDENTIFIER),
    INDEX IDX_CRS_CRASH_DATE        (CRS_CRASH_DATE),
    INDEX IDX_CRS_SEVERITY          (CRS_CRASH_SEVERITY_CODE),
    INDEX IDX_CRS_COUNTY            (CRS_COUNTY_FIPS_CODE),
    INDEX IDX_CRS_CITY              (CRS_CITY_PLACE_CODE),
    INDEX IDX_CRS_LOCATION          (CRS_LATITUDE, CRS_LONGITUDE)
) ENGINE=InnoDB COMMENT='MMUCC Crash Data Elements C1-C27. Central entity for all crash records.';
