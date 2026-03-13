-- =============================================================================
-- V1__crash_schema.sql
-- crash-service Flyway baseline migration
-- Creates: CRASH_TBL, VEHICLE_TBL, ROADWAY_TBL, 6 multi-value child tables,
--          CRASH_AUDIT_LOG_TBL
-- Uses CREATE TABLE IF NOT EXISTS throughout so re-runs are safe.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- CRASH_TBL  (C1–C27)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CRASH_TBL (
    CRS_CRASH_ID                        BIGINT          NOT NULL AUTO_INCREMENT,
    CRS_CRASH_IDENTIFIER                VARCHAR(50),
    CRS_CRASH_TYPE_CODE                 INT,
    CRS_FIRST_HARMFUL_EVENT_CODE        INT,
    CRS_CRASH_DATE                      DATE,
    CRS_CRASH_TIME                      TIME,
    CRS_COUNTY_FIPS_CODE                VARCHAR(10),
    CRS_COUNTY_NAME                     VARCHAR(100),
    CRS_CITY_PLACE_CODE                 VARCHAR(10),
    CRS_CITY_PLACE_NAME                 VARCHAR(100),
    CRS_ROUTE_ID                        VARCHAR(50),
    CRS_ROUTE_TYPE_CODE                 INT,
    CRS_ROUTE_DIRECTION_CODE            INT,
    CRS_DISTANCE_FROM_REF_MILES         DECIMAL(8,3),
    CRS_REF_POINT_DIRECTION_CODE        INT,
    CRS_LATITUDE                        DECIMAL(10,7),
    CRS_LONGITUDE                       DECIMAL(10,7),
    CRS_LOC_FIRST_HARMFUL_EVENT         INT,
    CRS_MANNER_COLLISION_CODE           INT,
    CRS_SOURCE_OF_INFO_CODE             INT,
    CRS_LIGHT_CONDITION_CODE            INT,
    CRS_JUNCTION_INTERCHANGE_FLG        INT,
    CRS_JUNCTION_LOCATION_CODE          INT,
    CRS_INTERSECTION_APPROACHES         INT,
    CRS_INTERSECTION_GEOMETRY_CODE      INT,
    CRS_INTERSECTION_TRAFFIC_CTL        INT,
    CRS_SCHOOL_BUS_RELATED_CODE         INT,
    CRS_WORK_ZONE_RELATED_CODE          INT,
    CRS_WORK_ZONE_LOCATION_CODE         INT,
    CRS_WORK_ZONE_TYPE_CODE             INT,
    CRS_WORK_ZONE_WORKERS_CODE          INT,
    CRS_WORK_ZONE_LAW_ENF_CODE          INT,
    CRS_CRASH_SEVERITY_CODE             INT,
    CRS_NUM_MOTOR_VEHICLES              INT,
    CRS_NUM_MOTORISTS                   INT,
    CRS_NUM_NON_MOTORISTS               INT,
    CRS_NUM_NON_FATALLY_INJURED         INT,
    CRS_NUM_FATALITIES                  INT,
    CRS_ALCOHOL_INVOLVEMENT_CODE        INT,
    CRS_DRUG_INVOLVEMENT_CODE           INT,
    CRS_DAY_OF_WEEK_CODE                INT,
    -- Audit columns
    CRS_CREATED_BY                      VARCHAR(100)    NOT NULL,
    CRS_CREATED_DT                      DATETIME        NOT NULL,
    CRS_MODIFIED_BY                     VARCHAR(100),
    CRS_MODIFIED_DT                     DATETIME,
    CRS_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_CRASH PRIMARY KEY (CRS_CRASH_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------------------------------
-- VEHICLE_TBL  (V1–V24)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VEHICLE_TBL (
    VEH_VEHICLE_ID                      BIGINT          NOT NULL AUTO_INCREMENT,
    VEH_CRASH_ID                        BIGINT          NOT NULL,
    VEH_VIN                             VARCHAR(17),
    VEH_UNIT_TYPE_CODE                  INT,
    VEH_UNIT_NUMBER                     INT,
    VEH_REGISTRATION_STATE              VARCHAR(10),
    VEH_REGISTRATION_YEAR               YEAR,
    VEH_LICENSE_PLATE                   VARCHAR(20),
    VEH_MAKE                            VARCHAR(50),
    VEH_MODEL_YEAR                      YEAR,
    VEH_MODEL                           VARCHAR(50),
    VEH_BODY_TYPE_CODE                  INT,
    VEH_TRAILING_UNITS_COUNT            INT,
    VEH_VEHICLE_SIZE_CODE               INT,
    VEH_HM_PLACARD_FLG                  INT,
    VEH_TOTAL_OCCUPANTS                 INT,
    VEH_SPECIAL_FUNCTION_CODE           INT,
    VEH_EMERGENCY_USE_CODE              INT,
    VEH_SPEED_LIMIT_MPH                 INT,
    VEH_DIRECTION_OF_TRAVEL_CODE        INT,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE      INT,
    VEH_TRAFFICWAY_DIVIDED_CODE         INT,
    VEH_TRAFFICWAY_BARRIER_CODE         INT,
    VEH_TRAFFICWAY_HOV_HOT_CODE         INT,
    VEH_TRAFFICWAY_HOV_CRASH_FLG        INT,
    VEH_TOTAL_THROUGH_LANES             INT,
    VEH_TOTAL_AUXILIARY_LANES           INT,
    VEH_ROADWAY_ALIGNMENT_CODE          INT,
    VEH_ROADWAY_GRADE_CODE              INT,
    VEH_MANEUVER_CODE                   INT,
    VEH_DAMAGE_INITIAL_CONTACT          INT,
    VEH_DAMAGE_EXTENT_CODE              INT,
    VEH_MOST_HARMFUL_EVENT_CODE         INT,
    VEH_HIT_AND_RUN_CODE                INT,
    VEH_TOWED_CODE                      INT,
    VEH_CONTRIBUTING_CIRC_CODE          INT,
    -- Audit columns
    VEH_CREATED_BY                      VARCHAR(100)    NOT NULL,
    VEH_CREATED_DT                      DATETIME        NOT NULL,
    VEH_MODIFIED_BY                     VARCHAR(100),
    VEH_MODIFIED_DT                     DATETIME,
    VEH_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_VEHICLE PRIMARY KEY (VEH_VEHICLE_ID),
    CONSTRAINT FK_VEHICLE_CRASH FOREIGN KEY (VEH_CRASH_ID)
        REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_VEHICLE_CRASH_ID ON VEHICLE_TBL (VEH_CRASH_ID);


-- -----------------------------------------------------------------------------
-- ROADWAY_TBL  (R1–R16)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ROADWAY_TBL (
    RWY_ROADWAY_ID                      BIGINT          NOT NULL AUTO_INCREMENT,
    RWY_CRASH_ID                        BIGINT          NOT NULL,
    RWY_BRIDGE_STRUCTURE_ID             VARCHAR(20),
    RWY_CURVE_RADIUS_FT                 DECIMAL(8,1),
    RWY_CURVE_LENGTH_FT                 DECIMAL(8,1),
    RWY_CURVE_SUPERELEVATION_PCT        DECIMAL(6,3),
    RWY_GRADE_DIRECTION                 VARCHAR(1),
    RWY_GRADE_PERCENT                   DECIMAL(5,2),
    RWY_NATIONAL_HWY_SYS_CODE          INT,
    RWY_FUNCTIONAL_CLASS_CODE           INT,
    RWY_AADT_YEAR                       YEAR,
    RWY_AADT_VALUE                      INT,
    RWY_AADT_TRUCK_MEASURE              VARCHAR(20),
    RWY_AADT_MOTORCYCLE_MEASURE         VARCHAR(20),
    RWY_LANE_WIDTH_FT                   DECIMAL(5,1),
    RWY_LEFT_SHOULDER_WIDTH_FT          DECIMAL(5,1),
    RWY_RIGHT_SHOULDER_WIDTH_FT         DECIMAL(5,1),
    RWY_MEDIAN_WIDTH_FT                 DECIMAL(6,1),
    RWY_ACCESS_CONTROL_CODE             INT,
    RWY_RAILWAY_CROSSING_ID             VARCHAR(10),
    RWY_ROADWAY_LIGHTING_CODE           INT,
    RWY_PAVEMENT_EDGELINE_CODE          INT,
    RWY_PAVEMENT_CENTERLINE_CODE        INT,
    RWY_PAVEMENT_LANE_LINE_CODE         INT,
    RWY_BICYCLE_FACILITY_CODE           INT,
    RWY_BICYCLE_SIGNED_ROUTE_CODE       INT,
    RWY_MAINLINE_LANES_COUNT            INT,
    RWY_CROSS_STREET_LANES_COUNT        INT,
    RWY_ENTERING_VEHICLES_YEAR          YEAR,
    RWY_ENTERING_VEHICLES_AADT          INT,
    -- Audit columns
    RWY_CREATED_BY                      VARCHAR(100)    NOT NULL,
    RWY_CREATED_DT                      DATETIME        NOT NULL,
    RWY_MODIFIED_BY                     VARCHAR(100),
    RWY_MODIFIED_DT                     DATETIME,
    RWY_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_ROADWAY PRIMARY KEY (RWY_ROADWAY_ID),
    CONSTRAINT UQ_ROADWAY_CRASH UNIQUE (RWY_CRASH_ID),
    CONSTRAINT FK_ROADWAY_CRASH FOREIGN KEY (RWY_CRASH_ID)
        REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- -----------------------------------------------------------------------------
-- CRASH_WEATHER_CONDITION_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CRASH_WEATHER_CONDITION_TBL (
    CWC_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    CWC_CRASH_ID                        BIGINT          NOT NULL,
    CWC_SEQUENCE_NUM                    INT             NOT NULL,
    CWC_WEATHER_CODE                    INT             NOT NULL,
    -- Audit columns
    CWC_CREATED_BY                      VARCHAR(100)    NOT NULL,
    CWC_CREATED_DT                      DATETIME        NOT NULL,
    CWC_MODIFIED_BY                     VARCHAR(100),
    CWC_MODIFIED_DT                     DATETIME,
    CWC_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_CWC PRIMARY KEY (CWC_ID),
    CONSTRAINT FK_CWC_CRASH FOREIGN KEY (CWC_CRASH_ID)
        REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_CWC_CRASH_ID ON CRASH_WEATHER_CONDITION_TBL (CWC_CRASH_ID);


-- -----------------------------------------------------------------------------
-- CRASH_SURFACE_CONDITION_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CRASH_SURFACE_CONDITION_TBL (
    CSC_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    CSC_CRASH_ID                        BIGINT          NOT NULL,
    CSC_SEQUENCE_NUM                    INT             NOT NULL,
    CSC_SURFACE_CODE                    INT             NOT NULL,
    -- Audit columns
    CSC_CREATED_BY                      VARCHAR(100)    NOT NULL,
    CSC_CREATED_DT                      DATETIME        NOT NULL,
    CSC_MODIFIED_BY                     VARCHAR(100),
    CSC_MODIFIED_DT                     DATETIME,
    CSC_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_CSC PRIMARY KEY (CSC_ID),
    CONSTRAINT FK_CSC_CRASH FOREIGN KEY (CSC_CRASH_ID)
        REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_CSC_CRASH_ID ON CRASH_SURFACE_CONDITION_TBL (CSC_CRASH_ID);


-- -----------------------------------------------------------------------------
-- CRASH_CONTRIBUTING_ROADWAY_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CRASH_CONTRIBUTING_ROADWAY_TBL (
    CCR_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    CCR_CRASH_ID                        BIGINT          NOT NULL,
    CCR_SEQUENCE_NUM                    INT             NOT NULL,
    CCR_CIRCUMSTANCE_CODE               INT             NOT NULL,
    -- Audit columns
    CCR_CREATED_BY                      VARCHAR(100)    NOT NULL,
    CCR_CREATED_DT                      DATETIME        NOT NULL,
    CCR_MODIFIED_BY                     VARCHAR(100),
    CCR_MODIFIED_DT                     DATETIME,
    CCR_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_CCR PRIMARY KEY (CCR_ID),
    CONSTRAINT FK_CCR_CRASH FOREIGN KEY (CCR_CRASH_ID)
        REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_CCR_CRASH_ID ON CRASH_CONTRIBUTING_ROADWAY_TBL (CCR_CRASH_ID);


-- -----------------------------------------------------------------------------
-- VEHICLE_TRAFFIC_CONTROL_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VEHICLE_TRAFFIC_CONTROL_TBL (
    VTC_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    VTC_VEHICLE_ID                      BIGINT          NOT NULL,
    VTC_CRASH_ID                        BIGINT          NOT NULL,
    VTC_SEQUENCE_NUM                    INT             NOT NULL,
    VTC_TCD_TYPE_CODE                   INT,
    VTC_TCD_INOPERATIVE_CODE            INT,
    -- Audit columns
    VTC_CREATED_BY                      VARCHAR(100)    NOT NULL,
    VTC_CREATED_DT                      DATETIME        NOT NULL,
    VTC_MODIFIED_BY                     VARCHAR(100),
    VTC_MODIFIED_DT                     DATETIME,
    VTC_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_VTC PRIMARY KEY (VTC_ID),
    CONSTRAINT FK_VTC_VEHICLE FOREIGN KEY (VTC_VEHICLE_ID)
        REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_VTC_VEHICLE_ID ON VEHICLE_TRAFFIC_CONTROL_TBL (VTC_VEHICLE_ID);


-- -----------------------------------------------------------------------------
-- VEHICLE_DAMAGE_AREA_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VEHICLE_DAMAGE_AREA_TBL (
    VDA_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    VDA_VEHICLE_ID                      BIGINT          NOT NULL,
    VDA_CRASH_ID                        BIGINT          NOT NULL,
    VDA_SEQUENCE_NUM                    INT             NOT NULL,
    VDA_AREA_CODE                       INT             NOT NULL,
    -- Audit columns
    VDA_CREATED_BY                      VARCHAR(100)    NOT NULL,
    VDA_CREATED_DT                      DATETIME        NOT NULL,
    VDA_MODIFIED_BY                     VARCHAR(100),
    VDA_MODIFIED_DT                     DATETIME,
    VDA_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_VDA PRIMARY KEY (VDA_ID),
    CONSTRAINT FK_VDA_VEHICLE FOREIGN KEY (VDA_VEHICLE_ID)
        REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_VDA_VEHICLE_ID ON VEHICLE_DAMAGE_AREA_TBL (VDA_VEHICLE_ID);


-- -----------------------------------------------------------------------------
-- VEHICLE_SEQUENCE_EVENT_TBL
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS VEHICLE_SEQUENCE_EVENT_TBL (
    VSE_ID                              BIGINT          NOT NULL AUTO_INCREMENT,
    VSE_VEHICLE_ID                      BIGINT          NOT NULL,
    VSE_CRASH_ID                        BIGINT          NOT NULL,
    VSE_SEQUENCE_NUM                    INT             NOT NULL,
    VSE_EVENT_CODE                      INT             NOT NULL,
    -- Audit columns
    VSE_CREATED_BY                      VARCHAR(100)    NOT NULL,
    VSE_CREATED_DT                      DATETIME        NOT NULL,
    VSE_MODIFIED_BY                     VARCHAR(100),
    VSE_MODIFIED_DT                     DATETIME,
    VSE_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_VSE PRIMARY KEY (VSE_ID),
    CONSTRAINT FK_VSE_VEHICLE FOREIGN KEY (VSE_VEHICLE_ID)
        REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_VSE_VEHICLE_ID ON VEHICLE_SEQUENCE_EVENT_TBL (VSE_VEHICLE_ID);


-- -----------------------------------------------------------------------------
-- CRASH_AUDIT_LOG_TBL  (append-only)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS CRASH_AUDIT_LOG_TBL (
    CAL_AUDIT_ID                        BIGINT          NOT NULL AUTO_INCREMENT,
    CAL_CRASH_ID                        INT,
    CAL_USER_ID                         INT,
    CAL_USERNAME                        VARCHAR(50)     NOT NULL,
    CAL_ACTION_CODE                     VARCHAR(20)     NOT NULL,
    CAL_TABLE_NAME                      VARCHAR(60)     NOT NULL,
    CAL_RECORD_ID                       INT,
    CAL_OLD_VALUE                       JSON,
    CAL_NEW_VALUE                       JSON,
    CAL_IP_ADDRESS                      VARCHAR(45),
    CAL_SESSION_ID                      VARCHAR(100),
    -- Audit columns (created only — MODIFIED columns always NULL; insertable=false/updatable=false in entity)
    CAL_CREATED_BY                      VARCHAR(100)    NOT NULL,
    CAL_CREATED_DT                      DATETIME        NOT NULL,
    CAL_MODIFIED_BY                     VARCHAR(100),
    CAL_MODIFIED_DT                     DATETIME,
    CAL_LAST_UPDATED_ACTIVITY_CODE      VARCHAR(20)     NOT NULL,
    CONSTRAINT PK_CAL PRIMARY KEY (CAL_AUDIT_ID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX IDX_CAL_CRASH_ID ON CRASH_AUDIT_LOG_TBL (CAL_CRASH_ID);
CREATE INDEX IDX_CAL_ACTION   ON CRASH_AUDIT_LOG_TBL (CAL_ACTION_CODE);
