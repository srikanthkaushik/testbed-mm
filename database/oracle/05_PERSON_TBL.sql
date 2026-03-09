-- =============================================================================
-- FILE:    05_PERSON_TBL.sql
-- PURPOSE: MMUCC Person Data Elements P1-P27
-- DBMS:    Oracle 19c
-- ACRONYM: PRS
-- =============================================================================

CREATE TABLE PERSON_TBL (
    PRS_PERSON_ID                     NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_PRS PRIMARY KEY,
    PRS_CRASH_ID                      NUMBER(10)      NOT NULL,
    PRS_VEHICLE_ID                    NUMBER(10),
    PRS_PERSON_NAME                   VARCHAR2(150),
    PRS_DOB_YEAR                      NUMBER(4),
    PRS_DOB_MONTH                     NUMBER(2),
    PRS_DOB_DAY                       NUMBER(2),
    PRS_AGE_YEARS                     NUMBER(3),
    PRS_SEX_CODE                      NUMBER(3),
    PRS_PERSON_TYPE_CODE              NUMBER(3),
    PRS_INCIDENT_RESPONDER_CODE       NUMBER(3),
    PRS_INJURY_STATUS_CODE            NUMBER(3),
    PRS_VEHICLE_UNIT_NUMBER           NUMBER(3),
    PRS_SEATING_ROW_CODE              NUMBER(3),
    PRS_SEATING_SEAT_CODE             NUMBER(3),
    PRS_RESTRAINT_CODE                NUMBER(3),
    PRS_RESTRAINT_IMPROPER_FLG        NUMBER(3),
    PRS_EJECTION_CODE                 NUMBER(3),
    PRS_DL_JURISDICTION_TYPE          NUMBER(3),
    PRS_DL_JURISDICTION_CODE          VARCHAR2(10),
    PRS_DL_NUMBER                     VARCHAR2(30),
    PRS_DL_CLASS_CODE                 NUMBER(3),
    PRS_DL_IS_CDL_FLG                 NUMBER(3),
    PRS_DL_ENDORSEMENT_CODE           NUMBER(3),
    PRS_SPEEDING_CODE                 NUMBER(3),
    PRS_VIOLATION_CODE_1              VARCHAR2(20),
    PRS_VIOLATION_CODE_2              VARCHAR2(20),
    PRS_DL_ALCOHOL_INTERLOCK_FLG      NUMBER(3),
    PRS_DL_STATUS_TYPE_CODE           NUMBER(3),
    PRS_DL_STATUS_CODE                NUMBER(3),
    PRS_DISTRACTED_ACTION_CODE        NUMBER(3),
    PRS_DISTRACTED_SOURCE_CODE        NUMBER(3),
    PRS_CONDITION_CODE_1              NUMBER(3),
    PRS_CONDITION_CODE_2              NUMBER(3),
    PRS_LE_SUSPECTS_ALCOHOL           NUMBER(3),
    PRS_ALCOHOL_TEST_STATUS_CODE      NUMBER(3),
    PRS_ALCOHOL_TEST_TYPE_CODE        NUMBER(3),
    PRS_ALCOHOL_BAC_RESULT            VARCHAR2(10),
    PRS_LE_SUSPECTS_DRUG              NUMBER(3),
    PRS_DRUG_TEST_STATUS_CODE         NUMBER(3),
    PRS_DRUG_TEST_TYPE_CODE           NUMBER(3),
    PRS_TRANSPORT_SOURCE_CODE         NUMBER(3),
    PRS_EMS_AGENCY_ID                 VARCHAR2(50),
    PRS_EMS_RUN_NUMBER                VARCHAR2(50),
    PRS_MEDICAL_FACILITY              VARCHAR2(100),
    PRS_INJURY_AREA_CODE              NUMBER(3),
    PRS_INJURY_DIAGNOSIS              CLOB,
    PRS_INJURY_SEVERITY_CODE          NUMBER(3),
    -- Audit Columns
    PRS_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    PRS_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    PRS_MODIFIED_BY                   VARCHAR2(100),
    PRS_MODIFIED_DT                   DATE,
    PRS_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE PERSON_TBL IS 'MMUCC Person Data Elements P1-P27. One row per person per crash.';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN PERSON_TBL.PRS_PERSON_ID                  IS 'Surrogate primary key for person record.';
COMMENT ON COLUMN PERSON_TBL.PRS_CRASH_ID                   IS 'FK to CRASH_TBL. Every person record must be associated with a crash.';
COMMENT ON COLUMN PERSON_TBL.PRS_VEHICLE_ID                 IS 'FK to VEHICLE_TBL. NULL for non-motorists (person type codes 4-9).';
COMMENT ON COLUMN PERSON_TBL.PRS_PERSON_NAME                IS 'Full name of person involved in crash.';
COMMENT ON COLUMN PERSON_TBL.PRS_DOB_YEAR                   IS 'P2: Year component of date of birth (4-digit year).';
COMMENT ON COLUMN PERSON_TBL.PRS_DOB_MONTH                  IS 'P2: Month component of date of birth (1-12).';
COMMENT ON COLUMN PERSON_TBL.PRS_DOB_DAY                    IS 'P2: Day component of date of birth (1-31).';
COMMENT ON COLUMN PERSON_TBL.PRS_AGE_YEARS                  IS 'P3: Age of person in years at time of crash.';
COMMENT ON COLUMN PERSON_TBL.PRS_SEX_CODE                   IS 'P4 SF2: Sex of person. 1=Female, 2=Male, 99=Unknown.';
COMMENT ON COLUMN PERSON_TBL.PRS_PERSON_TYPE_CODE           IS 'P4 SF1: Person type. 1=Driver, 2=Passenger, 3=Occupant MV Not in Transport, 4=Bicyclist, 5=Other Cyclist, 6=Pedestrian, 7=Other Pedestrian, 8=Non-MV Transportation Device Occupant, 9=Unknown Non-Motorist, 99=Unknown. Codes 4-9 require Non-Motorist section.';
COMMENT ON COLUMN PERSON_TBL.PRS_INCIDENT_RESPONDER_CODE    IS 'P4 SF3: Indicates if person is an incident responder.';
COMMENT ON COLUMN PERSON_TBL.PRS_INJURY_STATUS_CODE         IS 'P5: Injury status. 1=Fatal(K), 2=Suspected Serious(A), 3=Suspected Minor(B), 4=Possible(C), 5=No Apparent Injury(O). Code 1 requires Fatal Section.';
COMMENT ON COLUMN PERSON_TBL.PRS_VEHICLE_UNIT_NUMBER        IS 'P6: Unit number of vehicle in which person was an occupant.';
COMMENT ON COLUMN PERSON_TBL.PRS_SEATING_ROW_CODE           IS 'P7 SF1: Row of seating position within vehicle.';
COMMENT ON COLUMN PERSON_TBL.PRS_SEATING_SEAT_CODE          IS 'P7 SF2: Seat position within row.';
COMMENT ON COLUMN PERSON_TBL.PRS_RESTRAINT_CODE             IS 'P8: Restraint system use code.';
COMMENT ON COLUMN PERSON_TBL.PRS_RESTRAINT_IMPROPER_FLG     IS 'P8 SF2: Indicates improper use of restraint system.';
COMMENT ON COLUMN PERSON_TBL.PRS_EJECTION_CODE              IS 'P9: Ejection status of occupant.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_JURISDICTION_TYPE       IS 'P10 SF1: Type of driver license jurisdiction (state, country, etc.).';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_JURISDICTION_CODE       IS 'P10 SF2: Jurisdiction code for driver license (state abbreviation or country code).';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_NUMBER                  IS 'P10 SF3: Driver license number.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_CLASS_CODE              IS 'P11: Driver license class code.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_IS_CDL_FLG              IS 'P11 SF2: Indicates if license is a Commercial Driver License.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_ENDORSEMENT_CODE        IS 'P11 SF3: CDL endorsement code.';
COMMENT ON COLUMN PERSON_TBL.PRS_SPEEDING_CODE              IS 'P17: Speeding-related contributing circumstance code.';
COMMENT ON COLUMN PERSON_TBL.PRS_VIOLATION_CODE_1           IS 'P18 SF1: First citation/violation code issued to person.';
COMMENT ON COLUMN PERSON_TBL.PRS_VIOLATION_CODE_2           IS 'P18 SF2: Second citation/violation code issued to person.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_ALCOHOL_INTERLOCK_FLG   IS 'P19: Indicates presence of alcohol ignition interlock device.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_STATUS_TYPE_CODE        IS 'P20 SF1: Type of driver license status restriction.';
COMMENT ON COLUMN PERSON_TBL.PRS_DL_STATUS_CODE             IS 'P20 SF2: Driver license status code.';
COMMENT ON COLUMN PERSON_TBL.PRS_DISTRACTED_ACTION_CODE     IS 'P21 SF1: Distracted driving action code.';
COMMENT ON COLUMN PERSON_TBL.PRS_DISTRACTED_SOURCE_CODE     IS 'P21 SF2: Source of distraction code.';
COMMENT ON COLUMN PERSON_TBL.PRS_CONDITION_CODE_1           IS 'P22 SF1: First driver/non-motorist condition code.';
COMMENT ON COLUMN PERSON_TBL.PRS_CONDITION_CODE_2           IS 'P22 SF2: Second driver/non-motorist condition code.';
COMMENT ON COLUMN PERSON_TBL.PRS_LE_SUSPECTS_ALCOHOL        IS 'P23 SF1: Law enforcement suspicion of alcohol involvement.';
COMMENT ON COLUMN PERSON_TBL.PRS_ALCOHOL_TEST_STATUS_CODE   IS 'P23 SF2: Status of alcohol test administered.';
COMMENT ON COLUMN PERSON_TBL.PRS_ALCOHOL_TEST_TYPE_CODE     IS 'P23 SF3: Type of alcohol test administered.';
COMMENT ON COLUMN PERSON_TBL.PRS_ALCOHOL_BAC_RESULT         IS 'P23 SF4: Blood alcohol concentration test result value.';
COMMENT ON COLUMN PERSON_TBL.PRS_LE_SUSPECTS_DRUG           IS 'P24 SF1: Law enforcement suspicion of drug involvement.';
COMMENT ON COLUMN PERSON_TBL.PRS_DRUG_TEST_STATUS_CODE      IS 'P24 SF2: Status of drug test administered.';
COMMENT ON COLUMN PERSON_TBL.PRS_DRUG_TEST_TYPE_CODE        IS 'P24 SF3: Type of drug test administered.';
COMMENT ON COLUMN PERSON_TBL.PRS_TRANSPORT_SOURCE_CODE      IS 'P25 SF1: Source of transportation to medical facility.';
COMMENT ON COLUMN PERSON_TBL.PRS_EMS_AGENCY_ID              IS 'P25 SF2: EMS agency identifier.';
COMMENT ON COLUMN PERSON_TBL.PRS_EMS_RUN_NUMBER             IS 'P25 SF3: EMS run/call number.';
COMMENT ON COLUMN PERSON_TBL.PRS_MEDICAL_FACILITY           IS 'P25 SF4: Name or identifier of medical facility.';
COMMENT ON COLUMN PERSON_TBL.PRS_INJURY_AREA_CODE           IS 'P26 SF1: Body area of most severe injury.';
COMMENT ON COLUMN PERSON_TBL.PRS_INJURY_DIAGNOSIS           IS 'P26 SF2: ICD-10 code or description from linked medical records.';
COMMENT ON COLUMN PERSON_TBL.PRS_INJURY_SEVERITY_CODE       IS 'P27: Injury severity code from medical records linkage.';
COMMENT ON COLUMN PERSON_TBL.PRS_CREATED_BY                 IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN PERSON_TBL.PRS_CREATED_DT                 IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN PERSON_TBL.PRS_MODIFIED_BY                IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN PERSON_TBL.PRS_MODIFIED_DT                IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN PERSON_TBL.PRS_LAST_UPDATED_ACTIVITY_CODE IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_PRS_CRASH_ID      ON PERSON_TBL (PRS_CRASH_ID);
CREATE INDEX IDX_PRS_VEHICLE_ID    ON PERSON_TBL (PRS_VEHICLE_ID);
CREATE INDEX IDX_PRS_PERSON_TYPE   ON PERSON_TBL (PRS_PERSON_TYPE_CODE);
CREATE INDEX IDX_PRS_INJURY_STATUS ON PERSON_TBL (PRS_INJURY_STATUS_CODE);
CREATE INDEX IDX_PRS_DOB           ON PERSON_TBL (PRS_DOB_YEAR, PRS_DOB_MONTH, PRS_DOB_DAY);
CREATE INDEX IDX_PRS_DL_NUMBER     ON PERSON_TBL (PRS_DL_NUMBER);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE PERSON_TBL
    ADD CONSTRAINT FK_PRS_CRASH
    FOREIGN KEY (PRS_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;

-- Note: Oracle does not support ON DELETE SET NULL directly in FK syntax.
-- PRS_VEHICLE_ID will be nulled by the application when a vehicle is deleted.
ALTER TABLE PERSON_TBL
    ADD CONSTRAINT FK_PRS_VEHICLE
    FOREIGN KEY (PRS_VEHICLE_ID)
    REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID);
