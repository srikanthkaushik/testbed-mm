-- =============================================================================
-- Table : PERSON_AIRBAG_TBL
-- Acronym: PAB
-- Source : MMUCC v5 P9 - Air Bag Deployed (select 1-4)
-- Notes : Child of PERSON_TBL. Up to 4 airbag deployment entries per person.
--         Level 2: All Occupants only.
-- =============================================================================
CREATE TABLE PERSON_AIRBAG_TBL (
    PAB_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    PAB_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL',
    PAB_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    PAB_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 airbag deployment entries per person.',
    PAB_AIRBAG_CODE                 TINYINT UNSIGNED    NOT NULL    COMMENT 'P9: Airbag deployment type. Values: 0=Not Deployed, 1=Curtain, 2=Front, 3=Side, 4=Other (knee/air belt), 5=Deployment Unknown, 97=Not Applicable',

    -- Audit Columns
    PAB_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    PAB_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    PAB_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    PAB_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    PAB_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (PAB_ID),
    UNIQUE KEY UQ_PAB_PERSON_SEQ    (PAB_PERSON_ID, PAB_SEQUENCE_NUM),
    INDEX IDX_PAB_PERSON_ID         (PAB_PERSON_ID),
    INDEX IDX_PAB_CRASH_ID          (PAB_CRASH_ID),
    CONSTRAINT FK_PAB_PERSON FOREIGN KEY (PAB_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_PAB_CRASH  FOREIGN KEY (PAB_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC P9: Air Bag Deployed. Multi-value child of PERSON_TBL (up to 4 per person).';
