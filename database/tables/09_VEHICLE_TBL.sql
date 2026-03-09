-- =============================================================================
-- Table : VEHICLE_TBL
-- Acronym: VEH
-- Source : MMUCC v5 Vehicle Data Elements V1 - V24
-- Notes : One row per motor vehicle involved in the crash.
--         Multi-value elements V17, V19 SF2, V20 stored in child tables.
-- =============================================================================
CREATE TABLE VEHICLE_TBL (
    VEH_VEHICLE_ID                  INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VEH_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL',

    -- V1: Vehicle Identification Number
    VEH_VIN                         VARCHAR(17)         NULL        COMMENT 'V1: Manufacturer-assigned VIN, permanently affixed to vehicle',

    -- V2: Motor Vehicle Unit Type and Number
    VEH_UNIT_TYPE_CODE              TINYINT UNSIGNED    NULL        COMMENT 'V2 SF1: Values: 1=Motor Vehicle in Transport, 2=Parked Motor Vehicle, 3=Working Vehicle/Equipment',
    VEH_UNIT_NUMBER                 TINYINT UNSIGNED    NULL        COMMENT 'V2 SF2: Sequential unit number assigned to this vehicle within the crash',

    -- V3: Motor Vehicle Registration
    VEH_REGISTRATION_STATE          VARCHAR(10)         NULL        COMMENT 'V3 SF1: ANSI/USPS state code or foreign country code (Appendix E/F); 00=No Driver Present, 99=Unknown',
    VEH_REGISTRATION_YEAR           YEAR                NULL        COMMENT 'V3 SF2: Year of registration as shown on plate',

    -- V4: License Plate Number
    VEH_LICENSE_PLATE               VARCHAR(20)         NULL        COMMENT 'V4: Alphanumeric plate identifier as displayed',

    -- V5-V7: Vehicle Identification
    VEH_MAKE                        VARCHAR(50)         NULL        COMMENT 'V5: Manufacturer-assigned make name',
    VEH_MODEL_YEAR                  YEAR                NULL        COMMENT 'V6: Manufacturer-assigned model year (YYYY)',
    VEH_MODEL                       VARCHAR(50)         NULL        COMMENT 'V7: Manufacturer-assigned model code or name',

    -- V8: Motor Vehicle Body Type Category
    VEH_BODY_TYPE_CODE              TINYINT UNSIGNED    NULL        COMMENT 'V8 SF1: FK to REF_BODY_TYPE_TBL. Values: 1-28, 98=Other. Types 14,17-27 require LV section.',
    VEH_TRAILING_UNITS_COUNT        TINYINT UNSIGNED    NULL        COMMENT 'V8 SF2: Number of trailing units. Values: 1-3 count, 97=Not Applicable (no trailing units)',
    VEH_VEHICLE_SIZE_CODE           TINYINT UNSIGNED    NULL        COMMENT 'V8 SF3: Values: 1=Light (<10,000 lbs GVWR/GCWR), 2=Medium (10,001-26,000 lbs), 3=Heavy (>26,000 lbs). Codes 2-3 require LV section.',
    VEH_HM_PLACARD_FLG              TINYINT UNSIGNED    NULL        COMMENT 'V8 SF4: Hazardous materials placard displayed? Values: 1=No, 2=Yes. Code 2 requires LV section.',

    -- V9: Total Occupants
    VEH_TOTAL_OCCUPANTS             TINYINT UNSIGNED    NULL        COMMENT 'V9: Total injured and uninjured occupants including driver. Must equal Person record count for this vehicle.',

    -- V10: Special Function
    VEH_SPECIAL_FUNCTION_CODE       TINYINT UNSIGNED    NULL        COMMENT 'V10: Values: 0=No Special Function, 1=Bus-School, 2=Bus-Childcare, 3=Bus-Transit, 4=Bus-Charter, 5=Bus-Intercity, 6=Bus-Shuttle, 7=Bus-Other, 8=Farm Vehicle, 9=Fire Truck, 10=Highway/Maintenance, 11=Mail Carrier, 12=Military, 13=Ambulance, 14=Police, 15=Public Utility, 16=Non-Transport Emergency, 17=Safety Service Patrol, 18=Other Incident Response, 19=Rental Truck (>10,000 lbs), 20=Towing Incident Response, 21=Crash Attenuator, 22=Taxi, 23=Ride-Hailing, 98=Other, 99=Unknown',

    -- V11: Emergency Motor Vehicle Use
    VEH_EMERGENCY_USE_CODE          TINYINT UNSIGNED    NULL        COMMENT 'V11: Values: 1=Non-Emergency Non-Transport, 2=Non-Emergency Transport, 3=Emergency No Warning Equipment, 4=Emergency With Warning Equipment, 97=Not Applicable, 99=Unknown',

    -- V12: Speed Limit
    VEH_SPEED_LIMIT_MPH             TINYINT UNSIGNED    NULL        COMMENT 'V12: Posted/statutory speed limit in mph. Values: numeric mph (should be divisible by 5), 97=Not Applicable, 99=Unknown',

    -- V13: Direction of Travel
    VEH_DIRECTION_OF_TRAVEL_CODE    TINYINT UNSIGNED    NULL        COMMENT 'V13: Direction before crash. Values: 0=Not on Roadway, 1=Northbound, 3=Eastbound, 6=Southbound, 9=Westbound, 99=Unknown',

    -- V14: Trafficway Description
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE  TINYINT UNSIGNED    NULL        COMMENT 'V14 SF1: Values: 1=One-Way, 2=Two-Way',
    VEH_TRAFFICWAY_DIVIDED_CODE     TINYINT UNSIGNED    NULL        COMMENT 'V14 SF2: Values: 0=Not Divided, 1=Not Divided With Continuous Left-Turn Lane, 2=Divided Flush Median (>4ft), 3=Divided Raised Median, 4=Divided Depressed Median, 99=Unknown',
    VEH_TRAFFICWAY_BARRIER_CODE     TINYINT UNSIGNED    NULL        COMMENT 'V14 SF3: Values: 0=No Barrier, 1=Cable Barrier, 2=Concrete Barrier, 3=Earth Embankment, 4=Guardrail, 98=Other',
    VEH_TRAFFICWAY_HOV_HOT_CODE     TINYINT UNSIGNED    NULL        COMMENT 'V14 SF4: HOV/HOT lane. Values: 0=None Present, 1=Separated (barrier/flush/raised/depressed), 2=Not Separated (painted markings)',
    VEH_TRAFFICWAY_HOV_CRASH_FLG    TINYINT UNSIGNED    NULL        COMMENT 'V14 SF5: Crash related to HOV/HOT lane? Values: 1=No, 2=Yes',

    -- V15: Total Lanes in Roadway
    VEH_TOTAL_THROUGH_LANES         TINYINT UNSIGNED    NULL        COMMENT 'V15 SF1: Number of through lanes (direction of travel for divided; both directions for undivided). 97=Not Applicable',
    VEH_TOTAL_AUXILIARY_LANES       TINYINT UNSIGNED    NULL        COMMENT 'V15 SF2: Number of auxiliary lanes. 97=Not Applicable',

    -- V16: Roadway Alignment and Grade
    VEH_ROADWAY_ALIGNMENT_CODE      TINYINT UNSIGNED    NULL        COMMENT 'V16 SF1: Horizontal alignment. Values: 1=Straight, 2=Curve Left, 3=Curve Right',
    VEH_ROADWAY_GRADE_CODE          TINYINT UNSIGNED    NULL        COMMENT 'V16 SF2: Grade. Values: 1=Level, 2=Uphill, 3=Hillcrest, 4=Downhill, 5=Sag (Bottom)',

    -- V17: Traffic Control Device - multi-value (1-4), stored in VEHICLE_TRAFFIC_CONTROL_TBL

    -- V18: Motor Vehicle Maneuver/Action
    VEH_MANEUVER_CODE               TINYINT UNSIGNED    NULL        COMMENT 'V18: Values: 1=Backing, 2=Changing Lanes, 3=Entering Traffic Lane, 4=Leaving Traffic Lane, 5=Making U-Turn, 6=Essentially Straight Ahead, 7=Negotiating Curve, 8=Overtaking/Passing, 9=Parked, 10=Slowing, 11=Stopped in Traffic, 12=Turning Left, 13=Turning Right, 98=Other, 99=Unknown',

    -- V19: Vehicle Damage
    VEH_DAMAGE_INITIAL_CONTACT      TINYINT UNSIGNED    NULL        COMMENT 'V19 SF1: Initial contact point (clock position). Values: 0=Non-Collision, 1-12=clock position, 13=Top, 14=Undercarriage, 15=Cargo Loss, 16=Vehicle Not at Scene, 99=Unknown',
    -- V19 SF2: Damaged areas (multi-value 1-13), stored in VEHICLE_DAMAGE_AREA_TBL
    VEH_DAMAGE_EXTENT_CODE          TINYINT UNSIGNED    NULL        COMMENT 'V19 SF3: Extent of damage. Values: 0=No Damage, 1=Minor, 2=Functional, 3=Disabling, 4=Vehicle Not at Scene',

    -- V20: Sequence of Events - multi-value (1-4), stored in VEHICLE_SEQUENCE_EVENT_TBL

    -- V21: Most Harmful Event
    VEH_MOST_HARMFUL_EVENT_CODE     TINYINT UNSIGNED    NULL        COMMENT 'V21: Most severe injury/damage event for this vehicle. Values: 1-41 event codes per MMUCC V21 attribute list',

    -- V22: Hit and Run
    VEH_HIT_AND_RUN_CODE            TINYINT UNSIGNED    NULL        COMMENT 'V22: Values: 1=No Did Not Leave Scene, 2=Yes Driver or Vehicle Left Scene',

    -- V23: Towed Due to Disabling Damage
    VEH_TOWED_CODE                  TINYINT UNSIGNED    NULL        COMMENT 'V23: Values: 0=Not Towed, 1=Towed But Not Disabling, 2=Towed Due to Disabling Damage',

    -- V24: Contributing Circumstances, Motor Vehicle
    VEH_CONTRIBUTING_CIRC_CODE      TINYINT UNSIGNED    NULL        COMMENT 'V24: Pre-existing defect. Values: 0=None, 1=Brakes, 2=Exhaust System, 3=Body/Doors, 4=Steering, 5=Power Train, 6=Suspension, 7=Tires, 8=Wheels, 9=Lights, 10=Windows/Windshield, 11=Mirrors, 12=Wipers, 13=Truck Coupling/Trailer Hitch, 98=Other, 99=Unknown',

    -- Audit Columns
    VEH_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VEH_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VEH_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VEH_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VEH_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VEH_VEHICLE_ID),
    INDEX IDX_VEH_CRASH_ID          (VEH_CRASH_ID),
    INDEX IDX_VEH_UNIT              (VEH_CRASH_ID, VEH_UNIT_NUMBER),
    INDEX IDX_VEH_VIN               (VEH_VIN),
    INDEX IDX_VEH_BODY_TYPE         (VEH_BODY_TYPE_CODE),
    CONSTRAINT FK_VEH_CRASH FOREIGN KEY (VEH_CRASH_ID) REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Vehicle Data Elements V1-V24. One row per vehicle per crash.';
