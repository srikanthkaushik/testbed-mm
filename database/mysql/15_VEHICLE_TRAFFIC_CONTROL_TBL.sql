-- =============================================================================
-- Table : VEHICLE_TRAFFIC_CONTROL_TBL
-- Acronym: VTC
-- Source : MMUCC v5 V17 - Traffic Control Device Type (select 1-4)
-- Notes : Child of VEHICLE_TBL. Up to 4 traffic control devices per vehicle.
-- =============================================================================
CREATE TABLE VEHICLE_TRAFFIC_CONTROL_TBL (
    VTC_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VTC_VEHICLE_ID                  INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_TBL',
    VTC_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    VTC_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 TCD types per vehicle.',
    VTC_TCD_TYPE_CODE               TINYINT UNSIGNED    NOT NULL    COMMENT 'V17 SF1: Traffic control device type. Values: 0=No Controls, 1=Person (flagger/LE/guard), 2=Bicycle Crossing Sign, 3=Curve Ahead Warning, 4=Intersection Ahead Warning, 5=Other Warning Sign, 6=Pedestrian Crossing Sign, 7=Railroad Crossing Sign, 8=Reduce Speed Ahead Warning, 9=School Zone Sign, 10=Stop Sign, 11=Yield Sign, 12=Flashing Railroad Signal (may include gates), 13=Flashing School Zone Signal, 14=Flashing Traffic Control Signal, 15=Lane Use Control Signal, 16=Other Signal, 17=Ramp Meter Signal, 18=Traffic Control Signal, 19=Bicycle Crossing Pavement Marking, 20=Other Pavement Marking, 21=Pedestrian Crossing Marking, 22=Railroad Crossing Marking, 23=School Zone Marking, 98=Other, 99=Unknown',
    VTC_TCD_INOPERATIVE_CODE        TINYINT UNSIGNED    NULL        COMMENT 'V17 SF2: Inoperative or missing TCD code. Values: 0=None Inoperative or Missing, 1-23=Same codes as SF1 indicating which device is inoperative/missing, 99=Unknown',

    -- Audit Columns
    VTC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VTC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VTC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VTC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VTC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VTC_ID),
    UNIQUE KEY UQ_VTC_VEHICLE_SEQ   (VTC_VEHICLE_ID, VTC_SEQUENCE_NUM),
    INDEX IDX_VTC_VEHICLE_ID        (VTC_VEHICLE_ID),
    INDEX IDX_VTC_CRASH_ID          (VTC_CRASH_ID),
    CONSTRAINT FK_VTC_VEHICLE FOREIGN KEY (VTC_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_VTC_CRASH   FOREIGN KEY (VTC_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC V17: Traffic Control Device Type. Multi-value child of VEHICLE_TBL (up to 4 per vehicle).';
