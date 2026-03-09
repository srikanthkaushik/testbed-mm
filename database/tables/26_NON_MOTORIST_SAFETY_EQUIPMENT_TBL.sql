-- =============================================================================
-- Table : NON_MOTORIST_SAFETY_EQUIPMENT_TBL
-- Acronym: NMS
-- Source : MMUCC v5 NM5 - Non-Motorist Safety Equipment (select 1-5)
-- Notes : Child of NON_MOTORIST_TBL. Up to 5 safety equipment items per non-motorist.
-- =============================================================================
CREATE TABLE NON_MOTORIST_SAFETY_EQUIPMENT_TBL (
    NMS_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    NMS_NMT_ID                      INT UNSIGNED        NOT NULL    COMMENT 'FK to NON_MOTORIST_TBL',
    NMS_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    NMS_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-5). MMUCC allows up to 5 safety equipment entries per non-motorist.',
    NMS_EQUIPMENT_CODE              TINYINT UNSIGNED    NOT NULL    COMMENT 'NM5: Safety equipment used by non-motorist. Values: 0=None (if selected no other values can be selected), 1=Helmet, 2=Protective Pads (elbows/knees/shins), 3=Reflective Wear (backpack/triangles), 4=Lighting, 5=Reflectors, 98=Other, 99=Unknown',

    -- Audit Columns
    NMS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    NMS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    NMS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    NMS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    NMS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (NMS_ID),
    UNIQUE KEY UQ_NMS_NMT_SEQ       (NMS_NMT_ID, NMS_SEQUENCE_NUM),
    INDEX IDX_NMS_NMT_ID            (NMS_NMT_ID),
    INDEX IDX_NMS_CRASH_ID          (NMS_CRASH_ID),
    CONSTRAINT FK_NMS_NMT   FOREIGN KEY (NMS_NMT_ID)   REFERENCES NON_MOTORIST_TBL (NMT_ID)       ON DELETE CASCADE,
    CONSTRAINT FK_NMS_CRASH FOREIGN KEY (NMS_CRASH_ID) REFERENCES CRASH_TBL        (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC NM5: Non-Motorist Safety Equipment. Multi-value child of NON_MOTORIST_TBL (up to 5 per non-motorist).';
