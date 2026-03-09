-- =============================================================================
-- FILE: 18_LARGE_VEHICLE_TBL.sql
-- TABLE: LARGE_VEHICLE_TBL
-- ACRONYM: LVH
-- DESCRIPTION: MMUCC LV1-LV11 Large Vehicle and HazMat Section.
--              One record per qualifying vehicle involved in a crash.
-- =============================================================================

CREATE TABLE LARGE_VEHICLE_TBL (
    LVH_ID                          NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_LVH PRIMARY KEY,
    LVH_VEHICLE_ID                  NUMBER(10)      NOT NULL,
    LVH_CRASH_ID                    NUMBER(10)      NOT NULL,

    -- LV1: CDL / Commercial Motor Vehicle License
    LVH_CMV_LICENSE_STATUS_CODE     NUMBER(3),
    LVH_CDL_COMPLIANCE_CODE         NUMBER(3),

    -- LV2: Trailer License Plates
    LVH_TRAILER1_PLATE              VARCHAR2(20),
    LVH_TRAILER2_PLATE              VARCHAR2(20),
    LVH_TRAILER3_PLATE              VARCHAR2(20),

    -- LV3: Trailer VINs
    LVH_TRAILER1_VIN                VARCHAR2(17),
    LVH_TRAILER2_VIN                VARCHAR2(17),
    LVH_TRAILER3_VIN                VARCHAR2(17),

    -- LV4: Trailer Makes
    LVH_TRAILER1_MAKE               VARCHAR2(50),
    LVH_TRAILER2_MAKE               VARCHAR2(50),
    LVH_TRAILER3_MAKE               VARCHAR2(50),

    -- LV5: Trailer Models
    LVH_TRAILER1_MODEL              VARCHAR2(50),
    LVH_TRAILER2_MODEL              VARCHAR2(50),
    LVH_TRAILER3_MODEL              VARCHAR2(50),

    -- LV6: Trailer Years
    LVH_TRAILER1_YEAR               NUMBER(4),
    LVH_TRAILER2_YEAR               NUMBER(4),
    LVH_TRAILER3_YEAR               NUMBER(4),

    -- LV7: Motor Carrier Identification
    LVH_CARRIER_ID_TYPE_CODE        NUMBER(3),
    LVH_CARRIER_COUNTRY_STATE       VARCHAR2(10),
    LVH_CARRIER_ID_NUMBER           VARCHAR2(20),
    LVH_CARRIER_NAME                VARCHAR2(150),
    LVH_CARRIER_STREET1             VARCHAR2(100),
    LVH_CARRIER_STREET2             VARCHAR2(100),
    LVH_CARRIER_CITY                VARCHAR2(100),
    LVH_CARRIER_STATE               VARCHAR2(10),
    LVH_CARRIER_ZIP                 VARCHAR2(20),
    LVH_CARRIER_COUNTRY             VARCHAR2(50),
    LVH_CARRIER_TYPE_CODE           NUMBER(3),

    -- LV8: Vehicle Configuration
    LVH_VEHICLE_CONFIG_CODE         NUMBER(3),
    LVH_VEHICLE_PERMITTED_CODE      NUMBER(3),

    -- LV9: Cargo Body Type
    LVH_CARGO_BODY_TYPE_CODE        NUMBER(3),

    -- LV10: Hazardous Materials
    LVH_HM_ID                       VARCHAR2(10),
    LVH_HM_CLASS                    VARCHAR2(5),
    LVH_HM_RELEASED_CODE            NUMBER(3),

    -- LV11: Axles
    LVH_AXLES_TRACTOR               NUMBER(3),
    LVH_AXLES_TRAILER1              NUMBER(3),
    LVH_AXLES_TRAILER2              NUMBER(3),
    LVH_AXLES_TRAILER3              NUMBER(3),

    -- Unique constraint: one large-vehicle record per vehicle
    CONSTRAINT UQ_LVH_VEHICLE_ID UNIQUE (LVH_VEHICLE_ID),

    -- Audit columns
    LVH_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    LVH_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    LVH_MODIFIED_BY                 VARCHAR2(100),
    LVH_MODIFIED_DT                 DATE,
    LVH_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL
);

-- -----------------------------------------------------------------------------
-- Table and column comments
-- -----------------------------------------------------------------------------
COMMENT ON TABLE LARGE_VEHICLE_TBL IS
    'MMUCC LV1-LV11 Large Vehicle and HazMat Section. One record per qualifying vehicle involved in a crash.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_ID IS
    'Surrogate primary key for the large vehicle record.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_VEHICLE_ID IS
    'Foreign key to VEHICLE_TBL. Unique: one large-vehicle record per vehicle.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL for query performance.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CMV_LICENSE_STATUS_CODE IS
    'LV1 SF1: CDL/CMV license status. 0=No CDL, 1=Cancelled or Denied, 2=Disqualified, 3=Expired, 4=Revoked, 5=Suspended, 6=Learners Permit, 7=Valid, 98=Other Not Valid, 99=Unknown.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CDL_COMPLIANCE_CODE IS
    'LV1 SF2: CDL endorsement compliance. 0=No Endorsement Required, 1=Endorsement Required Complied, 2=Endorsement Required Not Complied, 3=Endorsement Required Compliance Unknown, 99=Unknown if Required.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER1_PLATE IS 'LV2 SF1: License plate of trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER2_PLATE IS 'LV2 SF2: License plate of trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER3_PLATE IS 'LV2 SF3: License plate of trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER1_VIN IS 'LV3 SF1: VIN of trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER2_VIN IS 'LV3 SF2: VIN of trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER3_VIN IS 'LV3 SF3: VIN of trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER1_MAKE IS 'LV4 SF1: Make of trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER2_MAKE IS 'LV4 SF2: Make of trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER3_MAKE IS 'LV4 SF3: Make of trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER1_MODEL IS 'LV5 SF1: Model of trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER2_MODEL IS 'LV5 SF2: Model of trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER3_MODEL IS 'LV5 SF3: Model of trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER1_YEAR IS 'LV6 SF1: Model year of trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER2_YEAR IS 'LV6 SF2: Model year of trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_TRAILER3_YEAR IS 'LV6 SF3: Model year of trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_ID_TYPE_CODE IS
    'LV7 SF1: Carrier ID type. 1=US DOT Number, 2=State Number, 97=Not Applicable, 99=Unknown.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_COUNTRY_STATE IS
    'LV7 SF2: Country or state of the issuing authority for carrier ID.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_ID_NUMBER IS
    'LV7 SF3: Carrier identification number (US DOT or state-issued).';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_NAME IS
    'LV7 SF4: Name of the motor carrier.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_STREET1 IS
    'LV7 SF5: Carrier address street line 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_STREET2 IS
    'LV7 SF5: Carrier address street line 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_CITY IS
    'LV7 SF5: Carrier address city.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_STATE IS
    'LV7 SF5: Carrier address state or province.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_ZIP IS
    'LV7 SF5: Carrier address ZIP or postal code.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_COUNTRY IS
    'LV7 SF5: Carrier address country.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARRIER_TYPE_CODE IS
    'LV7 SF6: Carrier type. 1=Interstate Carrier, 2=Intrastate Carrier, 3=Not in Commerce/Government, 4=Not in Commerce/Other.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_VEHICLE_CONFIG_CODE IS
    'LV8 SF1: Vehicle configuration. 1=Vehicle 10000 lbs or less with HM placard, 2=Bus/Large Van (9-15 seats), 3=Bus (more than 15 seats), 4=Single-Unit Truck 2-axle GVWR>10000 lbs, 5=Single-Unit Truck 3+ axles, 6=Truck Pulling Trailers, 7=Truck Tractor Bobtail, 8=Truck Tractor/Semi-Trailer, 9=Truck Tractor/Double, 10=Truck Tractor/Triple, 11=Truck More Than 10000 lbs Cannot Classify, 99=Unknown.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_VEHICLE_PERMITTED_CODE IS
    'LV8 SF3: Oversize/overweight permit status. 1=Non-Permitted Load, 2=Permitted Load.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CARGO_BODY_TYPE_CODE IS
    'LV9: Cargo body type. 0=No Cargo Body, 1=Bus, 2=Auto Transporter, 3=Cargo Tank, 4=Concrete Mixer, 5=Dump, 6=Flatbed, 7=Garbage/Refuse, 8=Grain/Chips/Gravel, 9=Intermodal Container Chassis, 10=Log, 11=Pole-Trailer, 12=Van/Enclosed Box, 13=Vehicle Towing Another Vehicle, 97=Not Applicable, 98=Other, 99=Unknown.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_HM_ID IS
    'LV10 SF1: 4-digit Hazardous Material identification number.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_HM_CLASS IS
    'LV10 SF2: 1-digit Hazardous Material class number.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_HM_RELEASED_CODE IS
    'LV10 SF3: Was HazMat released? 1=No, 2=Yes, 97=Not Applicable, 99=Unknown.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_AXLES_TRACTOR IS
    'LV11 SF1: Number of axles on the tractor unit.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_AXLES_TRAILER1 IS
    'LV11 SF2: Number of axles on trailer 1.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_AXLES_TRAILER2 IS
    'LV11 SF3: Number of axles on trailer 2.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_AXLES_TRAILER3 IS
    'LV11 SF4: Number of axles on trailer 3.';

COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CREATED_BY IS
    'Audit: user or process that created this record.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_CREATED_DT IS
    'Audit: date/time this record was created. Defaults to SYSDATE.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_MODIFIED_BY IS
    'Audit: user or process that last modified this record.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_MODIFIED_DT IS
    'Audit: date/time this record was last modified.';
COMMENT ON COLUMN LARGE_VEHICLE_TBL.LVH_LAST_UPDATED_ACTIVITY_CODE IS
    'Audit: activity code of the last update operation.';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_LVH_CRASH_ID
    ON LARGE_VEHICLE_TBL (LVH_CRASH_ID);

CREATE INDEX IDX_LVH_CARRIER_ID
    ON LARGE_VEHICLE_TBL (LVH_CARRIER_ID_NUMBER);

CREATE INDEX IDX_LVH_HM_CLASS
    ON LARGE_VEHICLE_TBL (LVH_HM_CLASS);

-- -----------------------------------------------------------------------------
-- Foreign key constraints
-- -----------------------------------------------------------------------------
ALTER TABLE LARGE_VEHICLE_TBL
    ADD CONSTRAINT FK_LVH_VEHICLE
    FOREIGN KEY (LVH_VEHICLE_ID)
    REFERENCES VEHICLE_TBL (VEH_ID)
    ON DELETE CASCADE;

ALTER TABLE LARGE_VEHICLE_TBL
    ADD CONSTRAINT FK_LVH_CRASH
    FOREIGN KEY (LVH_CRASH_ID)
    REFERENCES CRASH_TBL (CRH_ID)
    ON DELETE CASCADE;
