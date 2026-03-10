-- =============================================================================
-- Table : PERSON_DL_RESTRICTION_TBL
-- Acronym: PDR
-- Source : MMUCC v5 P16 Subfield 1 - Driver License Restrictions (specify 1-3)
-- Notes : Child of PERSON_TBL. Up to 3 license restrictions per driver.
--         Level 3: All Drivers only.
-- =============================================================================
CREATE TABLE PERSON_DL_RESTRICTION_TBL (
    PDR_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    PDR_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL (must be a Driver: PRS_PERSON_TYPE_CODE=1)',
    PDR_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    PDR_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-3). MMUCC allows up to 3 restriction entries per driver.',
    PDR_RESTRICTION_CODE            TINYINT UNSIGNED    NOT NULL    COMMENT 'P16 SF1: License restriction. Values: 0=None, 1=Alcohol Interlock Device, 2=CDL Intrastate Only, 3=Corrective Lenses, 4=Farm Waiver, 5=Except Class A Bus, 6=Except Class A and B Bus, 7=Except Tractor-Trailer, 8=Intermediate License Restrictions, 9=Learners Permit Restrictions, 10=Limited to Daylight Only, 11=Limited to Employment, 12=Limited-Other, 13=Mechanical Devices (special brakes/hand controls/adaptive), 14=Military Vehicles Only, 15=Motor Vehicles Without Air Brakes, 16=Outside Mirror, 17=Prosthetic Aid, 98=Other',

    -- Audit Columns
    PDR_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    PDR_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    PDR_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    PDR_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    PDR_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (PDR_ID),
    UNIQUE KEY UQ_PDR_PERSON_SEQ    (PDR_PERSON_ID, PDR_SEQUENCE_NUM),
    INDEX IDX_PDR_PERSON_ID         (PDR_PERSON_ID),
    INDEX IDX_PDR_CRASH_ID          (PDR_CRASH_ID),
    CONSTRAINT FK_PDR_PERSON FOREIGN KEY (PDR_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_PDR_CRASH  FOREIGN KEY (PDR_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC P16 SF1: Driver License Restrictions. Multi-value child of PERSON_TBL (up to 3 per driver).';
