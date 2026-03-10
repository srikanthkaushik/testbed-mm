-- =============================================================================
-- Table : CRASH_CONTRIBUTING_ROADWAY_TBL
-- Acronym: CCR
-- Source : MMUCC v5 C14 - Contributing Circumstances - Roadway Environment (select 1-2)
-- Notes : Child of CRASH_TBL. Up to 2 roadway contributing circumstances per crash.
-- =============================================================================
CREATE TABLE CRASH_CONTRIBUTING_ROADWAY_TBL (
    CCR_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    CCR_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL',
    CCR_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-2). MMUCC allows up to 2 roadway contributing circumstances per crash.',
    CCR_CIRCUMSTANCE_CODE           TINYINT UNSIGNED    NOT NULL    COMMENT 'C14: Values: 0=None, 1=Roadway Surface Condition, 2=Shoulder Defect, 3=Roadway Obstruction, 4=Non-Highway Work, 5=Vision Obstruction, 6=Worn/Polished Surface, 7=Wet Surface, 8=Ice/Frost, 9=Snow/Slush, 10=Holes/Ruts/Bumps, 11=Shoulders, 12=Drop-Off at Edge of Pavement, 13=Soft Shoulders, 14=Low Shoulders, 15=Traffic Control Device Missing/Inoperative/Obscured, 16=Trees/Vegetation Obscuring Signs, 17=Animal/Object on Roadway, 18=Weather Conditions, 19=Work Zone Related, 98=Other, 99=Unknown',

    -- Audit Columns
    CCR_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    CCR_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    CCR_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    CCR_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    CCR_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (CCR_ID),
    UNIQUE KEY UQ_CCR_CRASH_SEQ     (CCR_CRASH_ID, CCR_SEQUENCE_NUM),
    INDEX IDX_CCR_CRASH_ID          (CCR_CRASH_ID),
    CONSTRAINT FK_CCR_CRASH FOREIGN KEY (CCR_CRASH_ID) REFERENCES CRASH_TBL (CRS_CRASH_ID) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC C14: Contributing Circumstances Roadway Environment. Multi-value child of CRASH_TBL (up to 2 per crash).';
