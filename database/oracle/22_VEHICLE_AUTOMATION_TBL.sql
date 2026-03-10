-- =============================================================================
-- Table : VEHICLE_AUTOMATION_TBL
-- Acronym: VAT
-- Source : MMUCC v5 DV1 Subfield 1 - Automation System Present
-- Notes : One row per vehicle that has automation present. UNIQUE on vehicle_id.
--         Parent of VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL and
--         VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL.
-- =============================================================================
CREATE TABLE VEHICLE_AUTOMATION_TBL (
    VAT_ID                          NUMBER(10)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_VAT PRIMARY KEY,
    VAT_VEHICLE_ID                  NUMBER(10)          NOT NULL,
    VAT_CRASH_ID                    NUMBER(10)          NOT NULL,
    VAT_AUTOMATION_PRESENT_CODE     NUMBER(3)           NOT NULL,

    -- Audit Columns
    VAT_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    VAT_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    VAT_MODIFIED_BY                 VARCHAR2(100),
    VAT_MODIFIED_DT                 DATE,
    VAT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        NOT NULL,

    CONSTRAINT UQ_VAT_VEHICLE_ID    UNIQUE (VAT_VEHICLE_ID)
);

COMMENT ON TABLE VEHICLE_AUTOMATION_TBL IS 'MMUCC DV1 SF1: Automation System Present. One row per vehicle with automation capability.';
COMMENT ON COLUMN VEHICLE_AUTOMATION_TBL.VAT_VEHICLE_ID IS 'FK to VEHICLE_TBL (the vehicle with automation)';
COMMENT ON COLUMN VEHICLE_AUTOMATION_TBL.VAT_CRASH_ID IS 'FK to CRASH_TBL (denormalized for query convenience)';
COMMENT ON COLUMN VEHICLE_AUTOMATION_TBL.VAT_AUTOMATION_PRESENT_CODE IS 'DV1 SF1: Values: 1=No Automation Present, 2=Automation Present, 99=Unknown if Automation Present';
COMMENT ON COLUMN VEHICLE_AUTOMATION_TBL.VAT_LAST_UPDATED_ACTIVITY_CODE IS 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved';

CREATE INDEX IDX_VAT_CRASH_ID ON VEHICLE_AUTOMATION_TBL (VAT_CRASH_ID);

ALTER TABLE VEHICLE_AUTOMATION_TBL ADD CONSTRAINT FK_VAT_VEHICLE
    FOREIGN KEY (VAT_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE;
ALTER TABLE VEHICLE_AUTOMATION_TBL ADD CONSTRAINT FK_VAT_CRASH
    FOREIGN KEY (VAT_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE;
