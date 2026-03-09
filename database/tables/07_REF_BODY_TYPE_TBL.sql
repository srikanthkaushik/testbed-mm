-- =============================================================================
-- Table : REF_BODY_TYPE_TBL
-- Acronym: RBT
-- Source : MMUCC v5 V8 Subfield 1 - Motor Vehicle Body Type Category
-- =============================================================================
CREATE TABLE REF_BODY_TYPE_TBL (
    RBT_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RBT_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for body type category',
    RBT_DESCRIPTION                 VARCHAR(100)        NOT NULL    COMMENT 'Human-readable body type description',
    RBT_REQUIRES_LV_SECTION         TINYINT(1)          NOT NULL    DEFAULT 0 COMMENT '1=Large Vehicle/HazMat section required when this body type is involved in qualifying crash; 0=Not required',

    -- Audit Columns
    RBT_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RBT_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RBT_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RBT_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RBT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RBT_ID),
    UNIQUE KEY UQ_RBT_CODE (RBT_CODE)
) ENGINE=InnoDB COMMENT='Reference: MMUCC V8 SF1 Motor Vehicle Body Type Category lookup values';

INSERT INTO REF_BODY_TYPE_TBL (RBT_CODE, RBT_DESCRIPTION, RBT_REQUIRES_LV_SECTION, RBT_CREATED_BY, RBT_LAST_UPDATED_ACTIVITY_CODE) VALUES
(1,  'All-Terrain Vehicle/ATC (ATV/ATC)',               0, 'SYSTEM', 'IMPORT'),
(2,  'Golf Cart',                                        0, 'SYSTEM', 'IMPORT'),
(3,  'Snowmobile',                                       0, 'SYSTEM', 'IMPORT'),
(4,  'Low Speed Vehicle',                                0, 'SYSTEM', 'IMPORT'),
(5,  'Moped or Motorized Bicycle',                       0, 'SYSTEM', 'IMPORT'),
(6,  'Recreational Off-Highway Vehicle (ROV)',           0, 'SYSTEM', 'IMPORT'),
(7,  '2-Wheeled Motorcycle',                             0, 'SYSTEM', 'IMPORT'),
(8,  '3-Wheeled Motorcycle',                             0, 'SYSTEM', 'IMPORT'),
(9,  'Autocycle',                                        0, 'SYSTEM', 'IMPORT'),
(10, 'Passenger Car',                                    0, 'SYSTEM', 'IMPORT'),
(11, 'Passenger Van (fewer than 9 seats)',               0, 'SYSTEM', 'IMPORT'),
(12, '(Sport) Utility Vehicle',                         0, 'SYSTEM', 'IMPORT'),
(13, 'Pickup',                                           0, 'SYSTEM', 'IMPORT'),
(14, 'Cargo Van',                                        1, 'SYSTEM', 'IMPORT'),
(15, 'Construction Equipment (backhoe, bulldozer, etc.)',0, 'SYSTEM', 'IMPORT'),
(16, 'Farm Equipment (tractor, combine harvester, etc.)',0, 'SYSTEM', 'IMPORT'),
(17, 'Single-Unit Truck',                                1, 'SYSTEM', 'IMPORT'),
(18, 'Truck Tractor',                                    1, 'SYSTEM', 'IMPORT'),
(19, 'Motor Home',                                       0, 'SYSTEM', 'IMPORT'),
(20, '9- or 12-Passenger Van',                           1, 'SYSTEM', 'IMPORT'),
(21, '15-Passenger Van',                                 1, 'SYSTEM', 'IMPORT'),
(22, 'Large Limo',                                       1, 'SYSTEM', 'IMPORT'),
(23, 'Mini-bus',                                         1, 'SYSTEM', 'IMPORT'),
(24, 'School Bus',                                       1, 'SYSTEM', 'IMPORT'),
(25, 'Transit Bus',                                      1, 'SYSTEM', 'IMPORT'),
(26, 'Motorcoach',                                       1, 'SYSTEM', 'IMPORT'),
(27, 'Other Bus Type',                                   1, 'SYSTEM', 'IMPORT'),
(28, 'Other Trucks',                                     0, 'SYSTEM', 'IMPORT'),
(98, 'Other',                                            0, 'SYSTEM', 'IMPORT');
