-- =============================================================================
-- Table : PERSON_DRUG_TEST_RESULT_TBL
-- Acronym: DTR
-- Source : MMUCC v5 P23 Subfield 3 - Drug Test Result (select 1-4)
-- Notes : Child of PERSON_TBL. Up to 4 drug test results per person.
--         Level 4: Drivers and Non-Motorists only.
-- =============================================================================
CREATE TABLE PERSON_DRUG_TEST_RESULT_TBL (
    DTR_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    DTR_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL',
    DTR_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',
    DTR_SEQUENCE_NUM                TINYINT UNSIGNED    NOT NULL    COMMENT 'Entry sequence (1-4). MMUCC allows up to 4 drug test result entries per person.',
    DTR_RESULT_CODE                 SMALLINT UNSIGNED   NOT NULL    COMMENT 'P23 SF3: Drug test result. Values: 1=Negative, 2=Amphetamine, 3=Cocaine, 4=Marijuana (Cannabinoid), 5=Opiate, 6=Other Controlled Substance, 7=PCP (Phencyclidine), 8=Other Drug (excludes post-crash drugs), 97=Not Applicable (Test Not Given), 99=Unknown. For detailed drug category codes see FARS Appendix I/J: 100-295=Narcotic, 300-395=Depressant, 400-495=Stimulant, 500-595=Hallucinogen, 600-695=Cannabinoid, 700-795=PCP, 800-895=Anabolic Steroid, 900-995=Inhalant',

    -- Audit Columns
    DTR_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    DTR_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    DTR_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    DTR_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    DTR_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (DTR_ID),
    UNIQUE KEY UQ_DTR_PERSON_SEQ    (DTR_PERSON_ID, DTR_SEQUENCE_NUM),
    INDEX IDX_DTR_PERSON_ID         (DTR_PERSON_ID),
    INDEX IDX_DTR_CRASH_ID          (DTR_CRASH_ID),
    CONSTRAINT FK_DTR_PERSON FOREIGN KEY (DTR_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_DTR_CRASH  FOREIGN KEY (DTR_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC P23 SF3: Drug Test Results. Multi-value child of PERSON_TBL (up to 4 results per person).';
