-- =============================================================================
-- Table : LARGE_VEHICLE_TBL
-- Acronym: LVH
-- Source : MMUCC v5 Large Vehicle & Hazardous Materials Section LV1 - LV11
-- Notes : One row per qualifying vehicle. Required when vehicle body type,
--         size, or HM placard flag triggers LV section (see REF_BODY_TYPE_TBL).
--         LV8 SF2 (Special Sizing, multi-value) stored in LV_SPECIAL_SIZING_TBL.
-- =============================================================================
CREATE TABLE LARGE_VEHICLE_TBL (
    LVH_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    LVH_VEHICLE_ID                  INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_TBL (the qualifying large vehicle)',
    LVH_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',

    -- LV1: CMV License Status and CDL Endorsement Compliance (Level 3 - Drivers)
    LVH_CMV_LICENSE_STATUS_CODE     TINYINT UNSIGNED    NULL        COMMENT 'LV1 SF1: CDL status of driver. Values: 0=No CDL, 1=Cancelled or Denied, 2=Disqualified, 3=Expired, 4=Revoked, 5=Suspended, 6=Learners Permit, 7=Valid, 98=Other Not Valid, 99=Unknown License Status',
    LVH_CDL_COMPLIANCE_CODE         TINYINT UNSIGNED    NULL        COMMENT 'LV1 SF2: CDL endorsement compliance. Values: 0=No Endorsement Required, 1=Endorsement Required Complied, 2=Endorsement Required Not Complied, 3=Endorsement Required Compliance Unknown, 99=Unknown if Required',

    -- LV2: Trailer License Plate Numbers (up to 3 trailers)
    LVH_TRAILER1_PLATE              VARCHAR(20)         NULL        COMMENT 'LV2 SF1: First trailer plate number; 97=Not Applicable (no trailing units)',
    LVH_TRAILER2_PLATE              VARCHAR(20)         NULL        COMMENT 'LV2 SF2: Second trailer plate number; 97=Not Applicable',
    LVH_TRAILER3_PLATE              VARCHAR(20)         NULL        COMMENT 'LV2 SF3: Third trailer plate number; 97=Not Applicable',

    -- LV3: Trailer VINs (up to 3)
    LVH_TRAILER1_VIN                VARCHAR(17)         NULL        COMMENT 'LV3 SF1: First trailer VIN; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER2_VIN                VARCHAR(17)         NULL        COMMENT 'LV3 SF2: Second trailer VIN; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER3_VIN                VARCHAR(17)         NULL        COMMENT 'LV3 SF3: Third trailer VIN; 97=Not Applicable, 99=Unknown',

    -- LV4: Trailer Makes (up to 3)
    LVH_TRAILER1_MAKE               VARCHAR(50)         NULL        COMMENT 'LV4 SF1: First trailer manufacturer name; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER2_MAKE               VARCHAR(50)         NULL        COMMENT 'LV4 SF2: Second trailer make; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER3_MAKE               VARCHAR(50)         NULL        COMMENT 'LV4 SF3: Third trailer make; 97=Not Applicable, 99=Unknown',

    -- LV5: Trailer Models (up to 3)
    LVH_TRAILER1_MODEL              VARCHAR(50)         NULL        COMMENT 'LV5 SF1: First trailer model; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER2_MODEL              VARCHAR(50)         NULL        COMMENT 'LV5 SF2: Second trailer model; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER3_MODEL              VARCHAR(50)         NULL        COMMENT 'LV5 SF3: Third trailer model; 97=Not Applicable, 99=Unknown',

    -- LV6: Trailer Model Years (up to 3)
    LVH_TRAILER1_YEAR               YEAR                NULL        COMMENT 'LV6 SF1: First trailer model year; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER2_YEAR               YEAR                NULL        COMMENT 'LV6 SF2: Second trailer model year; 97=Not Applicable, 99=Unknown',
    LVH_TRAILER3_YEAR               YEAR                NULL        COMMENT 'LV6 SF3: Third trailer model year; 97=Not Applicable, 99=Unknown',

    -- LV7: Motor Carrier Identification
    LVH_CARRIER_ID_TYPE_CODE        TINYINT UNSIGNED    NULL        COMMENT 'LV7 SF1: ID type. Values: 1=US DOT Number, 2=State Number, 97=Not Applicable, 99=Unknown/Unable to Determine',
    LVH_CARRIER_COUNTRY_STATE       VARCHAR(10)         NULL        COMMENT 'LV7 SF2: Country or US state code of carrier',
    LVH_CARRIER_ID_NUMBER           VARCHAR(20)         NULL        COMMENT 'LV7 SF3: US DOT number (up to 7 digits) or State-issued carrier ID',
    LVH_CARRIER_NAME                VARCHAR(150)        NULL        COMMENT 'LV7 SF4: Motor carrier company name',
    LVH_CARRIER_STREET1             VARCHAR(100)        NULL        COMMENT 'LV7 SF5: Carrier street address line 1',
    LVH_CARRIER_STREET2             VARCHAR(100)        NULL        COMMENT 'LV7 SF5: Carrier street address line 2',
    LVH_CARRIER_CITY                VARCHAR(100)        NULL        COMMENT 'LV7 SF5: Carrier city',
    LVH_CARRIER_STATE               VARCHAR(10)         NULL        COMMENT 'LV7 SF5: Carrier state code',
    LVH_CARRIER_ZIP                 VARCHAR(20)         NULL        COMMENT 'LV7 SF5: Carrier zip/postal code',
    LVH_CARRIER_COUNTRY             VARCHAR(50)         NULL        COMMENT 'LV7 SF5: Carrier country',
    LVH_CARRIER_TYPE_CODE           TINYINT UNSIGNED    NULL        COMMENT 'LV7 SF6: Type of carrier. Values: 1=Interstate Carrier, 2=Intrastate Carrier, 3=Not in Commerce/Government, 4=Not in Commerce/Other Truck or Bus',

    -- LV8: Vehicle Configuration
    LVH_VEHICLE_CONFIG_CODE         TINYINT UNSIGNED    NULL        COMMENT 'LV8 SF1: General vehicle configuration. Values: 1=Vehicle 10,000 lbs or less with HM placard, 2=Bus/Large Van (9-15 seats incl driver), 3=Bus (more than 15 seats incl driver), 4=Single-Unit Truck 2-axle GVWR>10,000 lbs, 5=Single-Unit Truck 3+ axles, 6=Truck Pulling Trailer(s), 7=Truck Tractor Bobtail, 8=Truck Tractor/Semi-Trailer, 9=Truck Tractor/Double, 10=Truck Tractor/Triple, 11=Truck More Than 10,000 lbs Cannot Classify, 99=Unknown',
    -- LV8 SF2: Special Sizing (multi-value 1-4) stored in LV_SPECIAL_SIZING_TBL
    LVH_VEHICLE_PERMITTED_CODE      TINYINT UNSIGNED    NULL        COMMENT 'LV8 SF3: Load permit status. Values: 1=Non-Permitted Load, 2=Permitted Load',

    -- LV9: Cargo Body Type
    LVH_CARGO_BODY_TYPE_CODE        TINYINT UNSIGNED    NULL        COMMENT 'LV9: Cargo body type. Values: 0=No Cargo Body (bobtail/light MV with HM placard), 1=Bus, 2=Auto Transporter, 3=Cargo Tank, 4=Concrete Mixer, 5=Dump, 6=Flatbed, 7=Garbage/Refuse, 8=Grain/Chips/Gravel, 9=Intermodal Container Chassis, 10=Log, 11=Pole-Trailer, 12=Van/Enclosed Box, 13=Vehicle Towing Another Vehicle, 97=Not Applicable (MV 10,000 lbs or less not displaying HM placard), 98=Other, 99=Unknown',

    -- LV10: Hazardous Materials (Cargo Only)
    LVH_HM_ID                       VARCHAR(10)         NULL        COMMENT 'LV10 SF1: 4-digit HM ID from diamond placard or rectangular box. Values: 0000=No HM Placard Displayed, xxxx=4-digit ID number, 9999=Unknown',
    LVH_HM_CLASS                    VARCHAR(5)          NULL        COMMENT 'LV10 SF2: 1-digit HM class number from bottom of diamond. Values: 00=No HM Placard, 1-9=Class number, 99=Unknown',
    LVH_HM_RELEASED_CODE            TINYINT UNSIGNED    NULL        COMMENT 'LV10 SF3: HM released from cargo? Values: 1=No, 2=Yes, 97=Not Applicable, 99=Unknown if Released',

    -- LV11: Total Number of Axles
    LVH_AXLES_TRACTOR               TINYINT UNSIGNED    NULL        COMMENT 'LV11 SF1: Number of axles on truck tractor; 99=Unknown',
    LVH_AXLES_TRAILER1              TINYINT UNSIGNED    NULL        COMMENT 'LV11 SF2: Axles on first trailer; 97=Not Applicable, 99=Unknown',
    LVH_AXLES_TRAILER2              TINYINT UNSIGNED    NULL        COMMENT 'LV11 SF3: Axles on second trailer; 97=Not Applicable, 99=Unknown',
    LVH_AXLES_TRAILER3              TINYINT UNSIGNED    NULL        COMMENT 'LV11 SF4: Axles on third trailer; 97=Not Applicable, 99=Unknown',

    -- Audit Columns
    LVH_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    LVH_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    LVH_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    LVH_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    LVH_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (LVH_ID),
    UNIQUE KEY UQ_LVH_VEHICLE_ID    (LVH_VEHICLE_ID),
    INDEX IDX_LVH_CRASH_ID          (LVH_CRASH_ID),
    INDEX IDX_LVH_CARRIER_ID        (LVH_CARRIER_ID_NUMBER),
    INDEX IDX_LVH_HM_CLASS          (LVH_HM_CLASS),
    CONSTRAINT FK_LVH_VEHICLE FOREIGN KEY (LVH_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_LVH_CRASH   FOREIGN KEY (LVH_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Large Vehicle & HazMat Section LV1-LV11. One row per qualifying vehicle per crash.';
