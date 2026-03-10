-- =============================================================================
-- Table : VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL
-- Acronym: VAI
-- Source : MMUCC v5 DV1 Subfield 2 - Automation System Levels in Vehicle (select 1-5)
-- Notes : Child of VEHICLE_AUTOMATION_TBL. Up to 5 automation levels per vehicle.
--         A vehicle may support multiple SAE J3016 automation levels.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL (
    VAI_ID                          NUMBER(10)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_VAI PRIMARY KEY,
    VAI_VAT_ID                      NUMBER(10)          NOT NULL,
    VAI_CRASH_ID                    NUMBER(10)          NOT NULL,
    VAI_SEQUENCE_NUM                NUMBER(3)           NOT NULL,
    VAI_AUTOMATION_LEVEL_CODE       NUMBER(3)           NOT NULL,

    -- Audit Columns
    VAI_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    VAI_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    VAI_MODIFIED_BY                 VARCHAR2(100),
    VAI_MODIFIED_DT                 DATE,
    VAI_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        NOT NULL,

    CONSTRAINT UQ_VAI_VAT_SEQ       UNIQUE (VAI_VAT_ID, VAI_SEQUENCE_NUM)
);

COMMENT ON TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL IS 'MMUCC DV1 SF2: Automation Levels Installed In Vehicle. Multi-value child of VEHICLE_AUTOMATION_TBL (up to 5).';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.VAI_VAT_ID IS 'FK to VEHICLE_AUTOMATION_TBL';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.VAI_CRASH_ID IS 'FK to CRASH_TBL (denormalized for query convenience)';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.VAI_SEQUENCE_NUM IS 'Entry sequence (1-5). A vehicle may support up to 5 distinct SAE J3016 automation levels.';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.VAI_AUTOMATION_LEVEL_CODE IS 'DV1 SF2: SAE J3016 level installed in vehicle. Values: 0=No Automation (Level 0), 1=Driver Assistance (Level 1), 2=Partial Automation (Level 2), 3=Conditional Automation (Level 3), 4=High Automation (Level 4), 5=Full Automation (Level 5), 6=Automation Level Unknown, 99=Unknown';
COMMENT ON COLUMN VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL.VAI_LAST_UPDATED_ACTIVITY_CODE IS 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved';

CREATE INDEX IDX_VAI_VAT_ID   ON VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL (VAI_VAT_ID);
CREATE INDEX IDX_VAI_CRASH_ID ON VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL (VAI_CRASH_ID);

ALTER TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL ADD CONSTRAINT FK_VAI_VAT
    FOREIGN KEY (VAI_VAT_ID)   REFERENCES VEHICLE_AUTOMATION_TBL (VAT_ID)       ON DELETE CASCADE;
ALTER TABLE VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL ADD CONSTRAINT FK_VAI_CRASH
    FOREIGN KEY (VAI_CRASH_ID) REFERENCES CRASH_TBL              (CRS_CRASH_ID) ON DELETE CASCADE;
