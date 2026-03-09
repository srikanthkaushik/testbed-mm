-- =============================================================================
-- Table : LV_SPECIAL_SIZING_TBL
-- Acronym: LVS
-- Source : MMUCC v5 LV8 Subfield 2 - Special Sizing (select 1-4)
-- Notes : Child of LARGE_VEHICLE_TBL. Up to 4 special sizing entries per vehicle.
-- =============================================================================
CREATE TABLE LV_SPECIAL_SIZING_TBL (
    LVS_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    LVS_LVH_ID                      INT UNSIGNED        NOT NULL    COMMENT 'FK to LARGE_VEHICLE_TBL',
    LVS_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    LVS_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 special sizing entries per large vehicle.',
    LVS_SIZING_CODE                 TINYINT UNSIGNED    NOT NULL    COMMENT 'LV8 SF2: Special sizing condition. Values: 0=No Special Sizing, 1=Over-height, 2=Over-length, 3=Over-weight, 4=Over-width',

    -- Audit Columns
    LVS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    LVS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    LVS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    LVS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    LVS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (LVS_ID),
    UNIQUE KEY UQ_LVS_LVH_SEQ       (LVS_LVH_ID, LVS_SEQUENCE_NUM),
    INDEX IDX_LVS_LVH_ID            (LVS_LVH_ID),
    INDEX IDX_LVS_CRASH_ID          (LVS_CRASH_ID),
    CONSTRAINT FK_LVS_LVH   FOREIGN KEY (LVS_LVH_ID)   REFERENCES LARGE_VEHICLE_TBL (LVH_ID)       ON DELETE CASCADE,
    CONSTRAINT FK_LVS_CRASH FOREIGN KEY (LVS_CRASH_ID) REFERENCES CRASH_TBL         (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC LV8 SF2: Special Sizing. Multi-value child of LARGE_VEHICLE_TBL (up to 4 per vehicle).';
