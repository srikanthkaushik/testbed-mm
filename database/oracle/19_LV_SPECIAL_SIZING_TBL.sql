-- =============================================================================
-- FILE: 19_LV_SPECIAL_SIZING_TBL.sql
-- TABLE: LV_SPECIAL_SIZING_TBL
-- ACRONYM: LVS
-- DESCRIPTION: MMUCC LV8 SF2 Special Sizing Characteristics.
--              Up to 4 records per large vehicle.
-- =============================================================================

CREATE TABLE LV_SPECIAL_SIZING_TBL (
    LVS_ID                          NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_LVS PRIMARY KEY,
    LVS_LVH_ID                      NUMBER(10)      NOT NULL,
    LVS_CRASH_ID                    NUMBER(10)      NOT NULL,
    LVS_SEQUENCE_NUM                NUMBER(3)       NOT NULL,
    LVS_SPECIAL_SIZING_CODE         NUMBER(3)       NOT NULL,

    -- Unique constraint: one sizing code entry per sequence per large vehicle
    CONSTRAINT UQ_LVS_LVH_SEQ UNIQUE (LVS_LVH_ID, LVS_SEQUENCE_NUM),

    -- Audit columns
    LVS_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    LVS_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    LVS_MODIFIED_BY                 VARCHAR2(100),
    LVS_MODIFIED_DT                 DATE,
    LVS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL
);

-- -----------------------------------------------------------------------------
-- Table and column comments
-- -----------------------------------------------------------------------------
COMMENT ON TABLE LV_SPECIAL_SIZING_TBL IS
    'MMUCC LV8 SF2 Special Sizing Characteristics for large vehicles. Up to 4 records per large vehicle.';

COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_ID IS
    'Surrogate primary key for the special sizing record.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_LVH_ID IS
    'Foreign key to LARGE_VEHICLE_TBL.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL for query performance.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_SEQUENCE_NUM IS
    'Sequence number of this sizing entry for the large vehicle (1-4).';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_SPECIAL_SIZING_CODE IS
    'LV8 SF2: Special sizing characteristic. 1=Oversize Vehicle, 2=Overweight Vehicle, 3=Oversize and Overweight, 4=Neither/No Permit Required, 97=Not Applicable, 99=Unknown.';

COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_CREATED_BY IS
    'Audit: user or process that created this record.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_CREATED_DT IS
    'Audit: date/time this record was created. Defaults to SYSDATE.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_MODIFIED_BY IS
    'Audit: user or process that last modified this record.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_MODIFIED_DT IS
    'Audit: date/time this record was last modified.';
COMMENT ON COLUMN LV_SPECIAL_SIZING_TBL.LVS_LAST_UPDATED_ACTIVITY_CODE IS
    'Audit: activity code of the last update operation.';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_LVS_LVH_ID
    ON LV_SPECIAL_SIZING_TBL (LVS_LVH_ID);

CREATE INDEX IDX_LVS_CRASH_ID
    ON LV_SPECIAL_SIZING_TBL (LVS_CRASH_ID);

-- -----------------------------------------------------------------------------
-- Foreign key constraints
-- -----------------------------------------------------------------------------
ALTER TABLE LV_SPECIAL_SIZING_TBL
    ADD CONSTRAINT FK_LVS_LVH
    FOREIGN KEY (LVS_LVH_ID)
    REFERENCES LARGE_VEHICLE_TBL (LVH_ID)
    ON DELETE CASCADE;

ALTER TABLE LV_SPECIAL_SIZING_TBL
    ADD CONSTRAINT FK_LVS_CRASH
    FOREIGN KEY (LVS_CRASH_ID)
    REFERENCES CRASH_TBL (CRH_ID)
    ON DELETE CASCADE;
