-- =============================================================================
-- Table : PERSON_TBL
-- Acronym: PRS
-- Source : MMUCC v5 Person Data Elements P1 - P27
-- Notes : One row per person involved in the crash (motorist or non-motorist).
--         Multi-value elements P9, P14, P16 SF1, P23 SF3 stored in child tables.
--         Levels: L1=All Persons, L2=All Occupants, L3=All Drivers,
--                 L4=Drivers+Non-Motorists, L5=All Injured
-- =============================================================================
CREATE TABLE PERSON_TBL (
    PRS_PERSON_ID                   INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    PRS_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL',
    PRS_VEHICLE_ID                  INT UNSIGNED        NULL        COMMENT 'FK to VEHICLE_TBL; NULL for non-motorists not linked to a specific vehicle',

    -- P1: Name (Level 1 - All Persons)
    PRS_PERSON_NAME                 VARCHAR(150)        NULL        COMMENT 'P1: Full name as obtained from driver license or other source',

    -- P2: Date of Birth / Age (Level 1)
    PRS_DOB_YEAR                    SMALLINT UNSIGNED   NULL        COMMENT 'P2 SF1: Birth year (YYYY). Use 9999 if unknown.',
    PRS_DOB_MONTH                   TINYINT UNSIGNED    NULL        COMMENT 'P2 SF1: Birth month (1-12). Use 99 if unknown.',
    PRS_DOB_DAY                     TINYINT UNSIGNED    NULL        COMMENT 'P2 SF1: Birth day (1-31). Use 99 if unknown.',
    PRS_AGE_YEARS                   TINYINT UNSIGNED    NULL        COMMENT 'P2 SF2: Age in years. Use only when date of birth cannot be obtained.',

    -- P3: Sex (Level 1)
    PRS_SEX_CODE                    TINYINT UNSIGNED    NULL        COMMENT 'P3: Values: 1=Female, 2=Male, 99=Unknown',

    -- P4: Person Type (Level 1)
    PRS_PERSON_TYPE_CODE            TINYINT UNSIGNED    NULL        COMMENT 'P4 SF1: FK to REF_PERSON_TYPE_TBL. Values: 1=Driver, 2=Passenger, 3=Occupant MV Not in Transport, 4=Bicyclist, 5=Other Cyclist, 6=Pedestrian, 7=Other Pedestrian, 8=Non-MV Transportation Device Occupant, 9=Unknown Non-Motorist, 99=Unknown. Codes 4-9 require Non-Motorist section.',
    PRS_INCIDENT_RESPONDER_CODE     TINYINT UNSIGNED    NULL        COMMENT 'P4 SF2: Values: 1=No, 2=EMS, 3=Fire, 4=Police, 5=Tow Operator, 6=Transportation Worker, 98=Other, 99=Unknown',

    -- P5: Injury Status (Level 1)
    PRS_INJURY_STATUS_CODE          TINYINT UNSIGNED    NULL        COMMENT 'P5: FK to REF_INJURY_STATUS_TBL. Values: 1=Fatal(K), 2=Suspected Serious(A), 3=Suspected Minor(B), 4=Possible(C), 5=No Apparent Injury(O). Code 1 requires Fatal Section.',

    -- P6: Occupant Vehicle Unit Number (Level 2 - All Occupants)
    PRS_VEHICLE_UNIT_NUMBER         TINYINT UNSIGNED    NULL        COMMENT 'P6: Unit number of vehicle this person occupied; links person to vehicle unit within the crash',

    -- P7: Seating Position (Level 2)
    PRS_SEATING_ROW_CODE            TINYINT UNSIGNED    NULL        COMMENT 'P7 SF1: Row. Values: 1=Front, 2=Second, 3=Third, 4=Fourth, 5=Other Row (bus/van), 6=Unknown Row, 11=Other Enclosed Cargo Area, 12=Riding on MV Exterior, 13=Sleeper Section of Cab, 14=Trailing Unit, 15=Unenclosed Cargo Area, 98=Not Applicable, 99=Unknown',
    PRS_SEATING_SEAT_CODE           TINYINT UNSIGNED    NULL        COMMENT 'P7 SF2: Seat position. Values: 7=Left (driver except postal/foreign), 8=Middle, 9=Right, 10=Unknown Seat. Not used when SF1 is 11-15/98/99.',

    -- P8: Restraint Systems / Motorcycle Helmet Use (Level 2)
    PRS_RESTRAINT_CODE              TINYINT UNSIGNED    NULL        COMMENT 'P8 SF1: Values: 1=Booster Seat, 2=Child Restraint Forward-Facing, 3=Child Restraint Rear-Facing, 4=Child Restraint Unknown, 5=Lap Belt Only, 6=None Used, 7=Restraint Unknown Type, 8=Shoulder and Lap Belt, 9=Shoulder Belt Only, 10=Stretcher, 11=Wheelchair, 12=DOT-Compliant Helmet, 13=Non-DOT-Compliant Helmet, 14=Unknown Helmet Compliance, 15=No Helmet, 97=Not Applicable, 98=Other, 99=Unknown',
    PRS_RESTRAINT_IMPROPER_FLG      TINYINT UNSIGNED    NULL        COMMENT 'P8 SF2: Improper use of restraint? Values: 1=No, 2=Yes',

    -- P9: Air Bag Deployed - multi-value (1-4), stored in PERSON_AIRBAG_TBL (Level 2)

    -- P10: Ejection (Level 2)
    PRS_EJECTION_CODE               TINYINT UNSIGNED    NULL        COMMENT 'P10: Values: 0=Not Ejected, 1=Ejected Partially, 2=Ejected Totally, 97=Not Applicable (motorcycle), 99=Unknown',

    -- P11: Driver License Jurisdiction (Level 3 - All Drivers)
    PRS_DL_JURISDICTION_TYPE        TINYINT UNSIGNED    NULL        COMMENT 'P11 SF1: Issuing jurisdiction type. Values: 0=Not Licensed, 1=Canada, 2=Indian Nation, 3=International, 4=Mexico, 5=State, 6=US Government, 97=Not Applicable (non-driver), 99=Unknown',
    PRS_DL_JURISDICTION_CODE        VARCHAR(10)         NULL        COMMENT 'P11 SF2: ANSI state FIPS code or ISO 3166-2 country/province code per Appendix E/F',

    -- P12: Driver License Number, Class, CDL, Endorsements (Level 3)
    PRS_DL_NUMBER                   VARCHAR(30)         NULL        COMMENT 'P12 SF1: License number alphanumeric identifier',
    PRS_DL_CLASS_CODE               TINYINT UNSIGNED    NULL        COMMENT 'P12 SF2: Values: 0=None, 1=Class A (GCWR 26,001+ lbs with towed >10,000 lbs), 2=Class B (single unit 26,001+ lbs), 3=Class C (16+ passengers or HazMat), 4=Class M (motorcycle/moped), 5=Regular Driver License, 97=Not Applicable',
    PRS_DL_IS_CDL_FLG               TINYINT UNSIGNED    NULL        COMMENT 'P12 SF3: Is commercial driver license? Values: 1=No, 2=Yes',
    PRS_DL_ENDORSEMENT_CODE         TINYINT UNSIGNED    NULL        COMMENT 'P12 SF4: Values: 0=None/Not Applicable, 1=H HazMat, 2=N Tank Vehicle, 3=P Passenger, 4=S School Bus, 5=T Double/Triple Trailers, 6=X Combo Tank+HazMat, 7=Other Non-Commercial',

    -- P13: Speeding-Related (Level 3)
    PRS_SPEEDING_CODE               TINYINT UNSIGNED    NULL        COMMENT 'P13: Values: 1=No, 2=Exceeded Speed Limit, 3=Racing, 4=Too Fast for Conditions, 99=Unknown',

    -- P14: Driver Actions - multi-value (1-4), stored in PERSON_DRIVER_ACTION_TBL (Level 3)

    -- P15: Violation Codes (Level 3)
    PRS_VIOLATION_CODE_1            VARCHAR(20)         NULL        COMMENT 'P15: Most critical violation code (State-specific code)',
    PRS_VIOLATION_CODE_2            VARCHAR(20)         NULL        COMMENT 'P15: Second most critical violation code (State-specific code)',

    -- P16: Driver License Restrictions (Level 3)
    -- P16 SF1: Restrictions 1-3, stored in PERSON_DL_RESTRICTION_TBL
    PRS_DL_ALCOHOL_INTERLOCK_FLG    TINYINT UNSIGNED    NULL        COMMENT 'P16 SF2: Alcohol interlock device present? Values: 1=No, 2=Yes, 99=Unknown',

    -- P17: Driver License Status (Level 3)
    PRS_DL_STATUS_TYPE_CODE         TINYINT UNSIGNED    NULL        COMMENT 'P17 SF1: Values: 1=Non-CDL Driver License, 2=Non-CDL Restricted (Learners/Temporary/Graduated), 3=Commercial Driver License (CDL)',
    PRS_DL_STATUS_CODE              TINYINT UNSIGNED    NULL        COMMENT 'P17 SF2: Current status. Values: 0=Not Licensed, 1=Cancelled or Denied, 2=Disqualified (CDL), 3=Expired, 4=Revoked, 5=Suspended, 6=Valid License, 99=Unknown',

    -- P18: Distracted By (Level 4 - Drivers and Non-Motorists)
    PRS_DISTRACTED_ACTION_CODE      TINYINT UNSIGNED    NULL        COMMENT 'P18 SF1: Distraction action. Values: 0=Not Distracted, 1=Talking/Listening, 2=Manually Operating (texting/dialing/game), 3=Other Action (looking away), 99=Unknown',
    PRS_DISTRACTED_SOURCE_CODE      TINYINT UNSIGNED    NULL        COMMENT 'P18 SF2: Distraction source. Values: 1=Hands-Free Mobile, 2=Hand-Held Mobile, 3=Other Electronic Device, 4=Vehicle-Integrated Device, 5=Passenger/Other Non-Motorist, 6=External to Vehicle, 7=Other Distraction, 97=Not Applicable (Not Distracted), 99=Unknown',

    -- P19: Condition at Time of Crash (Level 4, select 1-2)
    PRS_CONDITION_CODE_1            TINYINT UNSIGNED    NULL        COMMENT 'P19: Primary condition. Values: 0=Apparently Normal, 1=Asleep or Fatigued, 2=Emotional (depressed/angry/disturbed), 3=Ill/Fainted, 4=Physically Impaired, 5=Under Influence of Medications/Drugs/Alcohol, 97=Not Applicable, 98=Other, 99=Unknown',
    PRS_CONDITION_CODE_2            TINYINT UNSIGNED    NULL        COMMENT 'P19: Secondary condition (optional). Same values as PRS_CONDITION_CODE_1. Must not be 0 (Normal) if used.',

    -- P20: Law Enforcement Suspects Alcohol (Level 4)
    PRS_LE_SUSPECTS_ALCOHOL         TINYINT UNSIGNED    NULL        COMMENT 'P20: Values: 1=No, 2=Yes, 99=Unknown',

    -- P21: Alcohol Test (Level 4)
    PRS_ALCOHOL_TEST_STATUS_CODE    TINYINT UNSIGNED    NULL        COMMENT 'P21 SF1: Values: 0=Test Not Given, 1=Test Given, 2=Test Refused, 99=Unknown if Tested',
    PRS_ALCOHOL_TEST_TYPE_CODE      TINYINT UNSIGNED    NULL        COMMENT 'P21 SF2: Values: 1=Blood, 2=Breath, 3=Urine, 97=Not Applicable, 98=Other',
    PRS_ALCOHOL_BAC_RESULT          VARCHAR(10)         NULL        COMMENT 'P21 SF3: BAC value (000-940), Pending, 97=Not Applicable, 99=Unknown',

    -- P22: Law Enforcement Suspects Drug Use (Level 4)
    PRS_LE_SUSPECTS_DRUG            TINYINT UNSIGNED    NULL        COMMENT 'P22: Values: 1=No, 2=Yes, 99=Unknown',

    -- P23: Drug Test (Level 4)
    PRS_DRUG_TEST_STATUS_CODE       TINYINT UNSIGNED    NULL        COMMENT 'P23 SF1: Values: 0=Test Not Given, 1=Test Given, 2=Test Refused, 99=Unknown if Tested',
    PRS_DRUG_TEST_TYPE_CODE         TINYINT UNSIGNED    NULL        COMMENT 'P23 SF2: Values: 1=Blood, 2=Saliva, 3=Urine, 97=Not Applicable, 98=Other',
    -- P23 SF3: Drug results (1-4), stored in PERSON_DRUG_TEST_RESULT_TBL

    -- P24: Transported to First Medical Facility By (Level 5 - All Injured)
    PRS_TRANSPORT_SOURCE_CODE       TINYINT UNSIGNED    NULL        COMMENT 'P24 SF1: Values: 0=Not Transported, 1=EMS Air, 2=EMS Ground, 3=Law Enforcement, 98=Other, 99=Unknown',
    PRS_EMS_AGENCY_ID               VARCHAR(50)         NULL        COMMENT 'P24 SF2: EMS response agency identifier',
    PRS_EMS_RUN_NUMBER              VARCHAR(50)         NULL        COMMENT 'P24 SF3: EMS response run number',
    PRS_MEDICAL_FACILITY            VARCHAR(100)        NULL        COMMENT 'P24 SF4: Name or number of first medical facility receiving patient',

    -- P25: Injury Area (Level 5, from linked EMS/hospital records)
    PRS_INJURY_AREA_CODE            TINYINT UNSIGNED    NULL        COMMENT 'P25: Primary injured area. Values: 1=Head, 2=Face, 3=Neck, 4=Upper Extremity, 5=Thorax (chest), 6=Spine, 7=Abdomen and Pelvis, 8=Lower Extremity, 9=Unspecified',

    -- P26: Injury Diagnosis (Level 5, from linked records)
    PRS_INJURY_DIAGNOSIS            TEXT                NULL        COMMENT 'P26: ICD-10 code or description obtained from linked EMS, emergency department, or hospital discharge records',

    -- P27: Injury Severity - Clinical (Level 5, from linked records)
    PRS_INJURY_SEVERITY_CODE        TINYINT UNSIGNED    NULL        COMMENT 'P27: Clinically derived severity. Values: 1=Fatal, 2=Serious, 3=Moderate, 4=Minor, 5=No Injury, 99=Unknown. May use ISS or MAIS scores depending on State linkage system.',

    -- Audit Columns
    PRS_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    PRS_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    PRS_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    PRS_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    PRS_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (PRS_PERSON_ID),
    INDEX IDX_PRS_CRASH_ID          (PRS_CRASH_ID),
    INDEX IDX_PRS_VEHICLE_ID        (PRS_VEHICLE_ID),
    INDEX IDX_PRS_PERSON_TYPE       (PRS_PERSON_TYPE_CODE),
    INDEX IDX_PRS_INJURY_STATUS     (PRS_INJURY_STATUS_CODE),
    INDEX IDX_PRS_DOB               (PRS_DOB_YEAR, PRS_DOB_MONTH, PRS_DOB_DAY),
    INDEX IDX_PRS_DL_NUMBER         (PRS_DL_NUMBER),
    CONSTRAINT FK_PRS_CRASH   FOREIGN KEY (PRS_CRASH_ID)   REFERENCES CRASH_TBL   (CRS_CRASH_ID)   ON DELETE CASCADE,
    CONSTRAINT FK_PRS_VEHICLE FOREIGN KEY (PRS_VEHICLE_ID) REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='MMUCC Person Data Elements P1-P27. One row per person per crash.';
