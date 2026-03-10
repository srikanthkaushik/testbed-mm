-- =============================================================================
-- Table : VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL
-- Acronym: VAE
-- Source : MMUCC v5 DV1 Subfield 3 - Automation System Levels Engaged at Time of Crash (select 1-5)
-- Notes : Child of VEHICLE_AUTOMATION_TBL. Up to 5 engaged automation levels per vehicle.
--         Captures which specific automation features were active at crash time.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL (
    VAE_ID                          NUMBER(10)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_VAE PRIMARY KEY,
    VAE_VAT_ID                      NUMBER(10)          NOT NULL,
    VAE_CRASH_ID                    NUMBER(10)          NOT NULL,
    VAE_SEQUENCE_NUM                NUMBER(3)           NOT NULL,
    VAE_AUTOMATION_LEVEL_CODE       NUMBER(3)           NOT NULL,

    -- Audit Columns
    VAE_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    VAE_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    VAE_MODIFIED_BY                 VARCHAR2(100),
    VAE_MODIFIED_DT                 DATE,
    VAE_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        NOT NULL,

    CONSTRAINT UQ_VAE_VAT_SEQ       UNIQUE (VAE_VAT_ID, VAE_SEQUENCE_NUM)
);

COMMENT ON TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL IS 'MMUCC DV1 SF3: Automation Levels Engaged at Time of Crash. Multi-value child of VEHICLE_AUTOMATION_TBL (up to 5).';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.VAE_VAT_ID IS 'FK to VEHICLE_AUTOMATION_TBL';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.VAE_CRASH_ID IS 'FK to CRASH_TBL (denormalized for query convenience)';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.VAE_SEQUENCE_NUM IS 'Entry sequence (1-5). Records each automation level that was active at crash time.';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.VAE_AUTOMATION_LEVEL_CODE IS 'DV1 SF3: SAE J3016 automation level engaged at time of crash. Values: 0=No Automation (Level 0), 1=Driver Assistance (Level 1), 2=Partial Automation (Level 2), 3=Conditional Automation (Level 3), 4=High Automation (Level 4), 5=Full Automation (Level 5), 6=Automation Level Unknown, 99=Unknown';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.VAE_LAST_UPDATED_ACTIVITY_CODE IS 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved';

CREATE INDEX IDX_VAE_VAT_ID   ON VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL (VAE_VAT_ID);
CREATE INDEX IDX_VAE_CRASH_ID ON VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL (VAE_CRASH_ID);

ALTER TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL ADD CONSTRAINT FK_VAE_VAT
    FOREIGN KEY (VAE_VAT_ID)   REFERENCES VEHICLE_AUTOMATION_TBL (VAT_ID)       ON DELETE CASCADE;
ALTER TABLE VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL ADD CONSTRAINT FK_VAE_CRASH
    FOREIGN KEY (VAE_CRASH_ID) REFERENCES CRASH_TBL              (CRS_CRASH_ID) ON DELETE CASCADE;
