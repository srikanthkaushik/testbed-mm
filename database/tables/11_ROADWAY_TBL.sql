-- =============================================================================
-- Table : ROADWAY_TBL
-- Acronym: RWY
-- Source : MMUCC v5 Roadway Data Elements R1 - R16
-- Notes : One row per crash. Data typically linked from roadway inventory files
--         using crash location (C6). One-to-one with CRASH_TBL.
-- =============================================================================
CREATE TABLE ROADWAY_TBL (
    RWY_ROADWAY_ID                  INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    RWY_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (one roadway record per crash)',

    -- R1: Bridge/Structure Identification Number
    RWY_BRIDGE_STRUCTURE_ID         VARCHAR(20)         NULL        COMMENT 'R1: Federal NBI (National Bridge Inventory) identifier. Required when C7 First Harmful Event = bridge structure codes.',

    -- R2: Roadway Curvature
    RWY_CURVE_RADIUS_FT             DECIMAL(8,1)        NULL        COMMENT 'R2 SF1: Curve radius in feet. 977=Not Applicable.',
    RWY_CURVE_LENGTH_FT             DECIMAL(8,1)        NULL        COMMENT 'R2 SF2: Curve length in feet.',
    RWY_CURVE_SUPERELEVATION_PCT    DECIMAL(6,3)        NULL        COMMENT 'R2 SF3: Superelevation as percent.',

    -- R3: Grade
    RWY_GRADE_DIRECTION             CHAR(1)             NULL        COMMENT 'R3 SF1: Direction of slope. Values: + (rise/uphill), - (fall/downhill)',
    RWY_GRADE_PERCENT               DECIMAL(5,2)        NULL        COMMENT 'R3 SF2: Percent of slope to nearest percent',

    -- R4: Part of National Highway System
    RWY_NATIONAL_HWY_SYS_CODE       TINYINT UNSIGNED    NULL        COMMENT 'R4: Values: 1=No, 2=Yes, 99=Unknown',

    -- R5: Roadway Functional Class
    RWY_FUNCTIONAL_CLASS_CODE       TINYINT UNSIGNED    NULL        COMMENT 'R5: Rural: 1=Interstate, 2=Principal Arterial Other Freeway/Expressway, 3=Principal Arterial Other, 4=Minor Arterial, 5=Major Collector, 6=Minor Collector, 7=Local, 8=Unknown Rural. Urban: 9=Interstate, 10=Principal Arterial Other Freeway/Expressway, 11=Principal Arterial Other, 12=Minor Arterial, 13=Collector, 14=Local, 15=Unknown Urban. 99=Unknown',

    -- R6: Annual Average Daily Traffic
    RWY_AADT_YEAR                   YEAR                NULL        COMMENT 'R6 SF1: Calendar year of AADT measurement',
    RWY_AADT_VALUE                  INT UNSIGNED        NULL        COMMENT 'R6 SF2: Annual Average Daily Traffic count',
    RWY_AADT_TRUCK_MEASURE          VARCHAR(20)         NULL        COMMENT 'R6 SF3: Truck (>10,000 lbs) count or percentage',
    RWY_AADT_MOTORCYCLE_MEASURE     VARCHAR(20)         NULL        COMMENT 'R6 SF4: Motorcycle count or percentage',

    -- R7: Widths of Lane(s) and Shoulder(s)
    RWY_LANE_WIDTH_FT               DECIMAL(5,1)        NULL        COMMENT 'R7 SF1: Lane width in feet',
    RWY_LEFT_SHOULDER_WIDTH_FT      DECIMAL(5,1)        NULL        COMMENT 'R7 SF2: Left shoulder width in feet',
    RWY_RIGHT_SHOULDER_WIDTH_FT     DECIMAL(5,1)        NULL        COMMENT 'R7 SF3: Right shoulder width in feet',

    -- R8: Width of Median
    RWY_MEDIAN_WIDTH_FT             DECIMAL(6,1)        NULL        COMMENT 'R8: Width of median in feet (travel lane edge to travel lane edge)',

    -- R9: Access Control
    RWY_ACCESS_CONTROL_CODE         TINYINT UNSIGNED    NULL        COMMENT 'R9: Values: 1=No Access Control, 2=Partial Access Control, 3=Full Access Control',

    -- R10: Railway Crossing ID
    RWY_RAILWAY_CROSSING_ID         VARCHAR(10)         NULL        COMMENT 'R10: US DOT/AAR unique railroad crossing identifier. Format: 0000000, nnnnnnA, or 9999999',

    -- R11: Roadway Lighting
    RWY_ROADWAY_LIGHTING_CODE       TINYINT UNSIGNED    NULL        COMMENT 'R11: Values: 1=Continuous Lighting Both Sides, 2=Continuous Lighting One Side, 3=No Lighting, 4=Spot Illumination Both Sides, 5=Spot Illumination One Side',

    -- R12: Pavement Markings, Longitudinal
    RWY_PAVEMENT_EDGELINE_CODE      TINYINT UNSIGNED    NULL        COMMENT 'R12 SF1: Edgeline. Values: 1=No Marked Edgeline, 2=Standard Width Edgeline, 3=Wide Edgeline, 98=Other',
    RWY_PAVEMENT_CENTERLINE_CODE    TINYINT UNSIGNED    NULL        COMMENT 'R12 SF2: Centerline. Values: 1=No Marked Centerline, 2=Centerline With Rumble Strip, 3=Standard Centerline Markings',
    RWY_PAVEMENT_LANE_LINE_CODE     TINYINT UNSIGNED    NULL        COMMENT 'R12 SF3: Lane lines. Values: 1=No Lane Markings, 2=Standard Lane Line, 3=Wide Lane Line',

    -- R13: Presence/Type of Bicycle Facility
    RWY_BICYCLE_FACILITY_CODE       TINYINT UNSIGNED    NULL        COMMENT 'R13 SF1: Values: 0=None, 1=Marked Bicycle Lane, 2=Separate Bicycle Path/Trail, 3=Unmarked Paved Shoulder, 4=Wide Curb Lane, 99=Unknown',
    RWY_BICYCLE_SIGNED_ROUTE_CODE   TINYINT UNSIGNED    NULL        COMMENT 'R13 SF2: Values: 1=No, 2=Yes, 97=Not Applicable, 99=Unknown',

    -- R14: Mainline Number of Lanes at Intersection
    RWY_MAINLINE_LANES_COUNT        TINYINT UNSIGNED    NULL        COMMENT 'R14: Through lanes on mainline approaches. Values: 0=Not Intersection/Interchange, 1=One Lane, 2=Two Lanes, 3=Three Lanes, 4=Four to Six Lanes, 5=Seven or More Lanes, 99=Unknown',

    -- R15: Cross-Street Number of Lanes at Intersection
    RWY_CROSS_STREET_LANES_COUNT    TINYINT UNSIGNED    NULL        COMMENT 'R15: Through lanes on side-road approaches. Same values as R14.',

    -- R16: Total Volume of Entering Vehicles (intersection)
    RWY_ENTERING_VEHICLES_YEAR      YEAR                NULL        COMMENT 'R16 SF1: Calendar year of entering vehicles AADT measurement',
    RWY_ENTERING_VEHICLES_AADT      INT UNSIGNED        NULL        COMMENT 'R16 SF2: Total entering vehicles for all approaches',

    -- Audit Columns
    RWY_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RWY_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RWY_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RWY_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RWY_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RWY_ROADWAY_ID),
    UNIQUE KEY UQ_RWY_CRASH_ID      (RWY_CRASH_ID),
    INDEX IDX_RWY_FUNCTIONAL_CLASS  (RWY_FUNCTIONAL_CLASS_CODE),
    CONSTRAINT FK_RWY_CRASH FOREIGN KEY (RWY_CRASH_ID) REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Roadway Data Elements R1-R16. One row per crash, linked from roadway inventory.';
