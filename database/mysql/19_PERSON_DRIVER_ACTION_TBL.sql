-- =============================================================================
-- Table : PERSON_DRIVER_ACTION_TBL
-- Acronym: PDA
-- Source : MMUCC v5 P14 - Driver Actions at Time of Crash (select 1-4)
-- Notes : Child of PERSON_TBL. Up to 4 driver actions per driver record.
--         Level 3: All Drivers only.
-- =============================================================================
CREATE TABLE PERSON_DRIVER_ACTION_TBL (
    PDA_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    PDA_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL (must be a Driver: PRS_PERSON_TYPE_CODE=1)',
    PDA_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    PDA_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 driver action entries per driver.',
    PDA_ACTION_CODE                 TINYINT UNSIGNED    NOT NULL    COMMENT 'P14: Driver action contributing to crash as judged by investigating officer. Values: 0=No Contributing Action, 1=Disregarded Other Road Markings, 2=Disregarded Other Traffic Sign, 3=Failed to Keep in Proper Lane, 4=Failed to Yield Right-of-Way, 5=Followed Too Closely, 6=Improper Backing, 7=Improper Passing, 8=Improper Turn, 9=Operated MV Inattentively/Carelessly/Negligently/Erratically, 10=Operated MV Recklessly or Aggressively, 11=Over-Correcting/Over-Steering, 12=Ran Off Roadway, 13=Ran Red Light, 14=Ran Stop Sign, 15=Swerved or Avoided (wind/slippery/object/non-motorist), 16=Wrong Side or Wrong Way, 98=Other Contributing Action, 99=Unknown',

    -- Audit Columns
    PDA_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    PDA_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    PDA_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    PDA_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    PDA_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (PDA_ID),
    UNIQUE KEY UQ_PDA_PERSON_SEQ    (PDA_PERSON_ID, PDA_SEQUENCE_NUM),
    INDEX IDX_PDA_PERSON_ID         (PDA_PERSON_ID),
    INDEX IDX_PDA_CRASH_ID          (PDA_CRASH_ID),
    CONSTRAINT FK_PDA_PERSON FOREIGN KEY (PDA_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_PDA_CRASH  FOREIGN KEY (PDA_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC P14: Driver Actions at Time of Crash. Multi-value child of PERSON_TBL (up to 4 per driver).';
