-- =============================================================================
-- Table : VEHICLE_SEQUENCE_EVENT_TBL
-- Acronym: VSE
-- Source : MMUCC v5 V20 - Sequence of Events (select 1-4)
-- Notes : Child of VEHICLE_TBL. Up to 4 sequential events per vehicle.
--         Sequence_num 1 = first/earliest event in sequence.
-- =============================================================================
CREATE TABLE VEHICLE_SEQUENCE_EVENT_TBL (
    VSE_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    VSE_VEHICLE_ID                  INT UNSIGNED        NOT NULL    COMMENT 'FK to VEHICLE_TBL',
    VSE_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    VSE_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Chronological event sequence for this vehicle (1=first event, up to 4)',
    VSE_EVENT_CODE                  TINYINT UNSIGNED    NOT NULL    COMMENT 'V20: Event code. Non-Harmful: 1-10. Non-Collision Harmful: 11-18. Collision with Person/MV/Non-Fixed: 19-29. Collision with Fixed Object: 30-51. All codes reference REF_HARMFUL_EVENT_TBL.',

    -- Audit Columns
    VSE_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    VSE_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    VSE_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    VSE_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    VSE_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (VSE_ID),
    UNIQUE KEY UQ_VSE_VEHICLE_SEQ   (VSE_VEHICLE_ID, VSE_SEQUENCE_NUM),
    INDEX IDX_VSE_VEHICLE_ID        (VSE_VEHICLE_ID),
    INDEX IDX_VSE_CRASH_ID          (VSE_CRASH_ID),
    INDEX IDX_VSE_EVENT_CODE        (VSE_EVENT_CODE),
    CONSTRAINT FK_VSE_VEHICLE FOREIGN KEY (VSE_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE CASCADE,
    CONSTRAINT FK_VSE_CRASH   FOREIGN KEY (VSE_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC V20: Sequence of Events. Multi-value child of VEHICLE_TBL (up to 4 events per vehicle in order).';
