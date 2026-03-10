-- =============================================================================
-- Table : VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL
-- Acronym: VAI
-- Source : MMUCC v5 DV1 Subfield 2 - Automation System Levels in Vehicle (select 1-5)
-- Notes : Child of VEHICLE_AUTOMATION_TBL. Up to 5 automation levels per vehicle.
--         A vehicle may have multiple automation features capable of different levels.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL (
    VAI_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VAI_VAT_ID                      INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_AUTOMATION_TBL',
    VAI_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    VAI_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-5). A vehicle may support up to 5 distinct automation levels.',
    VAI_AUTOMATION_LEVEL_CODE       TINYINT UNSIGNED    NOT NULL    COMMENT 'DV1 SF2: SAE J3016 automation level installed in vehicle. Values: 0=No Automation (Level 0 - human performs all driving), 1=Driver Assistance (Level 1 - system controls steering OR accel/decel), 2=Partial Automation (Level 2 - system controls both steering AND accel/decel), 3=Conditional Automation (Level 3 - system performs all driving with human fallback), 4=High Automation (Level 4 - system performs all driving, human fallback not required), 5=Full Automation (Level 5 - system performs all driving in all conditions), 6=Automation Level Unknown, 99=Unknown',

    -- Audit Columns
    VAI_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VAI_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VAI_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VAI_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VAI_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VAI_ID),
    UNIQUE KEY UQ_VAI_VAT_SEQ       (VAI_VAT_ID, VAI_SEQUENCE_NUM),
    INDEX IDX_VAI_VAT_ID            (VAI_VAT_ID),
    INDEX IDX_VAI_CRASH_ID          (VAI_CRASH_ID),
    CONSTRAINT FK_VAI_VAT   FOREIGN KEY (VAI_VAT_ID)   REFERENCES VEHICLE_AUTOMATION_TBL (VAT_ID)       ON DELETE CASCADE,
    CONSTRAINT FK_VAI_CRASH FOREIGN KEY (VAI_CRASH_ID) REFERENCES CRASH_TBL             (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC DV1 SF2: Automation Levels Installed In Vehicle. Multi-value child of VEHICLE_AUTOMATION_TBL (up to 5).';
