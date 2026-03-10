-- =============================================================================
-- Table : VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL
-- Acronym: VAE
-- Source : MMUCC v5 DV1 Subfield 3 - Automation System Levels Engaged at Time of Crash (select 1-5)
-- Notes : Child of VEHICLE_AUTOMATION_TBL. Up to 5 engaged automation levels per vehicle.
--         Captures which specific automation features were active at crash time.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL (
    VAE_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VAE_VAT_ID                      INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_AUTOMATION_TBL',
    VAE_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    VAE_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-5). Records each automation level that was active at crash time.',
    VAE_AUTOMATION_LEVEL_CODE       TINYINT UNSIGNED    NOT NULL    COMMENT 'DV1 SF3: SAE J3016 automation level engaged at time of crash. Values: 0=No Automation (Level 0), 1=Driver Assistance (Level 1), 2=Partial Automation (Level 2), 3=Conditional Automation (Level 3), 4=High Automation (Level 4), 5=Full Automation (Level 5), 6=Automation Level Unknown, 99=Unknown',

    -- Audit Columns
    VAE_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VAE_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VAE_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VAE_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VAE_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VAE_ID),
    UNIQUE KEY UQ_VAE_VAT_SEQ       (VAE_VAT_ID, VAE_SEQUENCE_NUM),
    INDEX IDX_VAE_VAT_ID            (VAE_VAT_ID),
    INDEX IDX_VAE_CRASH_ID          (VAE_CRASH_ID),
    CONSTRAINT FK_VAE_VAT   FOREIGN KEY (VAE_VAT_ID)   REFERENCES VEHICLE_AUTOMATION_TBL (VAT_ID)       ON DELETE CASCADE,
    CONSTRAINT FK_VAE_CRASH FOREIGN KEY (VAE_CRASH_ID) REFERENCES CRASH_TBL             (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC DV1 SF3: Automation Levels Engaged at Time of Crash. Multi-value child of VEHICLE_AUTOMATION_TBL (up to 5).';
