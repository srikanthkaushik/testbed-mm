-- =============================================================================
-- Table : VEHICLE_DAMAGE_AREA_TBL
-- Acronym: VDA
-- Source : MMUCC v5 V19 Subfield 2 - Location of Damaged Area(s) (enter 1-13)
-- Notes : Child of VEHICLE_TBL. Up to 13 damaged areas per vehicle.
-- =============================================================================
CREATE TABLE VEHICLE_DAMAGE_AREA_TBL (
    VDA_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VDA_VEHICLE_ID                  INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_TBL',
    VDA_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    VDA_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-13). MMUCC allows up to 13 damaged area entries per vehicle.',
    VDA_AREA_CODE                   TINYINT UNSIGNED    NOT NULL    COMMENT 'V19 SF2: Damaged area location using clock-point diagram. Values: 0=No Damage, 1=1 o-clock, 2=2 o-clock, 3=3 o-clock (Right), 4=4 o-clock, 5=5 o-clock, 6=6 o-clock (Rear), 7=7 o-clock, 8=8 o-clock, 9=9 o-clock (Left), 10=10 o-clock, 11=11 o-clock, 12=12 o-clock (Front), 13=Top, 14=Undercarriage, 15=All Areas, 16=Vehicle Not at Scene',

    -- Audit Columns
    VDA_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VDA_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VDA_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VDA_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VDA_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VDA_ID),
    UNIQUE KEY UQ_VDA_VEHICLE_SEQ   (VDA_VEHICLE_ID, VDA_SEQUENCE_NUM),
    INDEX IDX_VDA_VEHICLE_ID        (VDA_VEHICLE_ID),
    INDEX IDX_VDA_CRASH_ID          (VDA_CRASH_ID),
    CONSTRAINT FK_VDA_VEHICLE FOREIGN KEY (VDA_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_VDA_CRASH   FOREIGN KEY (VDA_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC V19 SF2: Location of Damaged Areas. Multi-value child of VEHICLE_TBL (up to 13 per vehicle).';
