-- =============================================================================
-- Table : CRASH_SURFACE_CONDITION_TBL
-- Acronym: CSC
-- Source : MMUCC v5 C13 - Roadway Surface Condition (select 1-4)
-- Notes : Child of CRASH_TBL. Up to 4 surface conditions per crash.
-- =============================================================================
CREATE TABLE CRASH_SURFACE_CONDITION_TBL (
    CSC_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    CSC_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL',
    CSC_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 surface conditions per crash.',
    CSC_SURFACE_CODE                TINYINT UNSIGNED    NOT NULL    COMMENT 'C13: FK to REF_SURFACE_CONDITION_TBL. Values: 1=Dry, 2=Wet, 3=Snow or Slush, 4=Ice, 5=Sand/Mud/Dirt/Oil/Gravel, 6=Water Standing or Moving, 7=Oil, 98=Other, 99=Unknown',

    -- Audit Columns
    CSC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    CSC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    CSC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    CSC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    CSC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (CSC_ID),
    UNIQUE KEY UQ_CSC_CRASH_SEQ     (CSC_CRASH_ID, CSC_SEQUENCE_NUM),
    INDEX IDX_CSC_CRASH_ID          (CSC_CRASH_ID),
    CONSTRAINT FK_CSC_CRASH FOREIGN KEY (CSC_CRASH_ID) REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC C13: Roadway Surface Condition. Multi-value child of CRASH_TBL (up to 4 per crash).';
