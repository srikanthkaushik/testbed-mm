-- =============================================================================
-- Table : FATAL_SECTION_TBL
-- Acronym: FSC
-- Source : MMUCC v5 Fatal Section Data Elements F1 - F3
-- Notes : One row per driver or non-motorist involved in a fatal crash.
--         Required when PERSON_TBL.PRS_INJURY_STATUS_CODE = 1 (Fatal).
--         Level 3 (F1): All Drivers. Level 4 (F2, F3): Drivers + Non-Motorists.
-- =============================================================================
CREATE TABLE FATAL_SECTION_TBL (
    FSC_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    FSC_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL (driver or non-motorist in a fatal crash)',
    FSC_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',

    -- F1: Attempted Avoidance Maneuver (Level 3 - All Drivers)
    FSC_AVOIDANCE_MANEUVER_CODE     TINYINT UNSIGNED    NULL        COMMENT 'F1: Driver action after realizing impending danger. Values: 0=No Driver Present/Unknown if Driver Present, 1=Accelerating, 2=Accelerating and Steering Left, 3=Accelerating and Steering Right, 4=Braking and Steering Left, 5=Braking and Steering Right, 6=Braking (Lockup), 7=Braking (Lockup Unknown), 8=Braking (No Lockup), 9=No Avoidance Maneuver, 10=Releasing Brakes, 11=Steering Left, 12=Steering Right, 98=Other Actions, 99=Unknown',

    -- F2: Alcohol Test Type and Results (Level 4 - Drivers and Non-Motorists)
    FSC_ALCOHOL_TEST_TYPE_CODE      TINYINT UNSIGNED    NULL        COMMENT 'F2 SF1: Test type used. Values: 0=Test Not Given, 1=Breath Test (AC), 2=Blood, 3=Blood Clot, 4=Blood Plasma/Serum, 5=Liver, 6=Preliminary Breath Test (PBT), 7=Unknown if Tested, 8=Urine, 9=Vitreous, 98=Other Test Type, 99=Unknown Test Type',
    FSC_ALCOHOL_TEST_RESULT         VARCHAR(10)         NULL        COMMENT 'F2 SF2: BAC test result. Values: 000-939=Actual BAC value, 940=0.94 or Greater, 996=Test Not Given, 997=AC Test Performed Results Unknown, 998=Positive Reading No Actual Value, 999=Unknown if Tested',

    -- F3: Drug Test Type and Results (Level 4 - Drivers and Non-Motorists)
    FSC_DRUG_TEST_TYPE_CODE         TINYINT UNSIGNED    NULL        COMMENT 'F3 SF1: Test type. Values: 0=Test Not Given, 1=Blood, 2=Both Blood and Urine, 3=Unknown Test Type, 4=Urine, 98=Other Test Type, 99=Unknown if Tested',
    FSC_DRUG_TEST_RESULT            SMALLINT UNSIGNED   NULL        COMMENT 'F3 SF2: Drug test result. Values: 0=Test Not Given, 1=Tested No Drugs Found/Negative, 100-295=Narcotic, 300-395=Depressant, 400-495=Stimulant, 500-595=Hallucinogen, 600-695=Cannabinoid, 700-795=PCP, 800-895=Anabolic Steroid, 900-995=Inhalant, 996=Other Drug, 997=Tested Results Unknown, 998=Tested Drugs Found Type Unknown/Positive, 999=Unknown if Tested. See MMUCC Appendix I/J for detailed drug codes.',

    -- Audit Columns
    FSC_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    FSC_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    FSC_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    FSC_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    FSC_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (FSC_ID),
    UNIQUE KEY UQ_FSC_PERSON_ID     (FSC_PERSON_ID),
    INDEX IDX_FSC_CRASH_ID          (FSC_CRASH_ID),
    CONSTRAINT FK_FSC_PERSON FOREIGN KEY (FSC_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_FSC_CRASH  FOREIGN KEY (FSC_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Fatal Section F1-F3. One row per driver/non-motorist involved in a fatal crash.';
