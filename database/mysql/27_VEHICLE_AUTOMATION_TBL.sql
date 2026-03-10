-- =============================================================================
-- Table : VEHICLE_AUTOMATION_TBL
-- Acronym: VAT
-- Source : MMUCC v5 Dynamic Data Element DV1 - Motor Vehicle Automated Driving System(s)
-- Notes : One row per vehicle with automation data. Dynamic element subject to
--         more frequent updates than other MMUCC elements.
--         DV1 SF2 and SF3 (multi-value automation levels) stored in child tables.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_TBL (
    VAT_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VAT_VEHICLE_ID                  INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_TBL',
    VAT_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',

    -- DV1 SF1: Automation System or Systems in Vehicle
    VAT_AUTOMATION_PRESENT_CODE     TINYINT UNSIGNED    NULL        COMMENT 'DV1 SF1: Automated driving system present in vehicle. Values: 1=No, 2=Yes, 99=Unknown',

    -- DV1 SF2: Automation System Levels in Vehicle - multi-value (1-5), stored in VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL
    -- DV1 SF3: Automation System Levels Engaged at Time of Crash - multi-value (1-5), stored in VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL

    -- Audit Columns
    VAT_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VAT_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VAT_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VAT_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VAT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VAT_ID),
    UNIQUE KEY UQ_VAT_VEHICLE_ID    (VAT_VEHICLE_ID),
    INDEX IDX_VAT_CRASH_ID          (VAT_CRASH_ID),
    CONSTRAINT FK_VAT_VEHICLE FOREIGN KEY (VAT_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_VAT_CRASH   FOREIGN KEY (VAT_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Dynamic Element DV1: Motor Vehicle Automated Driving Systems. One row per vehicle.';
