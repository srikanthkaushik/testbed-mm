-- =============================================================================
-- FILE:    06_ROADWAY_TBL.sql
-- PURPOSE: MMUCC Roadway Data Elements R1-R16
-- DBMS:    Oracle 19c
-- ACRONYM: RWY
-- =============================================================================

CREATE TABLE ROADWAY_TBL (
    RWY_ROADWAY_ID                    NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_RWY PRIMARY KEY,
    RWY_CRASH_ID                      NUMBER(10)      NOT NULL,
    RWY_BRIDGE_STRUCTURE_ID           VARCHAR2(20),
    RWY_CURVE_RADIUS_FT               NUMBER(8,1),
    RWY_CURVE_LENGTH_FT               NUMBER(8,1),
    RWY_CURVE_SUPERELEVATION_PCT      NUMBER(6,3),
    RWY_GRADE_DIRECTION               CHAR(1),
    RWY_GRADE_PERCENT                 NUMBER(5,2),
    RWY_NATIONAL_HWY_SYS_CODE         NUMBER(3),
    RWY_FUNCTIONAL_CLASS_CODE         NUMBER(3),
    RWY_AADT_YEAR                     NUMBER(4),
    RWY_AADT_VALUE                    NUMBER(10),
    RWY_AADT_TRUCK_MEASURE            VARCHAR2(20),
    RWY_AADT_MOTORCYCLE_MEASURE       VARCHAR2(20),
    RWY_LANE_WIDTH_FT                 NUMBER(5,1),
    RWY_LEFT_SHOULDER_WIDTH_FT        NUMBER(5,1),
    RWY_RIGHT_SHOULDER_WIDTH_FT       NUMBER(5,1),
    RWY_MEDIAN_WIDTH_FT               NUMBER(6,1),
    RWY_ACCESS_CONTROL_CODE           NUMBER(3),
    RWY_RAILWAY_CROSSING_ID           VARCHAR2(10),
    RWY_ROADWAY_LIGHTING_CODE         NUMBER(3),
    RWY_PAVEMENT_EDGELINE_CODE        NUMBER(3),
    RWY_PAVEMENT_CENTERLINE_CODE      NUMBER(3),
    RWY_PAVEMENT_LANE_LINE_CODE       NUMBER(3),
    RWY_BICYCLE_FACILITY_CODE         NUMBER(3),
    RWY_BICYCLE_SIGNED_ROUTE_CODE     NUMBER(3),
    RWY_MAINLINE_LANES_COUNT          NUMBER(3),
    RWY_CROSS_STREET_LANES_COUNT      NUMBER(3),
    RWY_ENTERING_VEHICLES_YEAR        NUMBER(4),
    RWY_ENTERING_VEHICLES_AADT        NUMBER(10),
    -- Audit Columns
    RWY_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    RWY_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    RWY_MODIFIED_BY                   VARCHAR2(100),
    RWY_MODIFIED_DT                   DATE,
    RWY_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL,
    -- Table Constraints
    CONSTRAINT UQ_RWY_CRASH_ID UNIQUE (RWY_CRASH_ID)
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE ROADWAY_TBL IS 'MMUCC Roadway Data Elements R1-R16. One row per crash (one-to-one with CRASH_TBL).';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN ROADWAY_TBL.RWY_ROADWAY_ID                  IS 'Surrogate primary key for roadway record.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CRASH_ID                    IS 'FK to CRASH_TBL. Unique — one roadway record per crash.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_BRIDGE_STRUCTURE_ID         IS 'R1: National Bridge Inventory structure number if crash occurred on a bridge.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CURVE_RADIUS_FT             IS 'R2 SF1: Radius of horizontal curve at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CURVE_LENGTH_FT             IS 'R2 SF2: Length of horizontal curve at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CURVE_SUPERELEVATION_PCT    IS 'R2 SF3: Superelevation (cross slope) of horizontal curve as a percentage.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_GRADE_DIRECTION             IS 'R3 SF1: Direction of roadway grade. + (upgrade) or - (downgrade) relative to direction of travel.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_GRADE_PERCENT               IS 'R3 SF2: Percent grade of roadway at crash location.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_NATIONAL_HWY_SYS_CODE       IS 'R4: Indicates if crash location is on National Highway System. 1=No, 2=Yes, 99=Unknown.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_FUNCTIONAL_CLASS_CODE       IS 'R5: Functional classification of roadway (e.g., Interstate, Principal Arterial, Local).';
COMMENT ON COLUMN ROADWAY_TBL.RWY_AADT_YEAR                   IS 'R6 SF1: Year of Annual Average Daily Traffic count.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_AADT_VALUE                  IS 'R6 SF2: Annual Average Daily Traffic count volume.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_AADT_TRUCK_MEASURE          IS 'R6 SF3: AADT truck measure or percentage.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_AADT_MOTORCYCLE_MEASURE     IS 'R6 SF4: AADT motorcycle measure or percentage.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_LANE_WIDTH_FT               IS 'R7 SF1: Width of travel lane at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_LEFT_SHOULDER_WIDTH_FT      IS 'R7 SF2: Width of left shoulder at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_RIGHT_SHOULDER_WIDTH_FT     IS 'R7 SF3: Width of right shoulder at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_MEDIAN_WIDTH_FT             IS 'R8: Width of median at crash location, in feet.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_ACCESS_CONTROL_CODE         IS 'R9: Degree of access control on roadway. 1=No, 2=Partial, 3=Full.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_RAILWAY_CROSSING_ID         IS 'R10: Federal Railroad Administration crossing inventory number.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_ROADWAY_LIGHTING_CODE       IS 'R11: Type of roadway lighting at crash location.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_PAVEMENT_EDGELINE_CODE      IS 'R12 SF1: Type or condition of pavement edge line marking.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_PAVEMENT_CENTERLINE_CODE    IS 'R12 SF2: Type or condition of pavement center line marking.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_PAVEMENT_LANE_LINE_CODE     IS 'R12 SF3: Type or condition of pavement lane line marking.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_BICYCLE_FACILITY_CODE       IS 'R13 SF1: Type of bicycle facility at crash location.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_BICYCLE_SIGNED_ROUTE_CODE   IS 'R13 SF2: Indicates presence of signed bicycle route.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_MAINLINE_LANES_COUNT        IS 'R14: Number of through travel lanes on mainline roadway.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CROSS_STREET_LANES_COUNT    IS 'R15: Number of through travel lanes on cross street.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_ENTERING_VEHICLES_YEAR      IS 'R16 SF1: Year of entering vehicles AADT count for intersection.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_ENTERING_VEHICLES_AADT      IS 'R16 SF2: Annual Average Daily Traffic of all vehicles entering intersection.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CREATED_BY                  IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_CREATED_DT                  IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_MODIFIED_BY                 IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_MODIFIED_DT                 IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN ROADWAY_TBL.RWY_LAST_UPDATED_ACTIVITY_CODE  IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_RWY_FUNCTIONAL_CLASS ON ROADWAY_TBL (RWY_FUNCTIONAL_CLASS_CODE);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE ROADWAY_TBL
    ADD CONSTRAINT FK_RWY_CRASH
    FOREIGN KEY (RWY_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
