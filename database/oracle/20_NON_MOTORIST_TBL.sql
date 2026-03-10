-- =============================================================================
-- Table : NON_MOTORIST_TBL
-- Acronym: NMT
-- Source : MMUCC v5 Non-Motorist Section Data Elements NM1 - NM6
-- Notes : One row per non-motorist person (PRS_PERSON_TYPE_CODE 4-9).
--         NM5 (Safety Equipment, multi-value 1-5) stored in NON_MOTORIST_SAFETY_EQUIPMENT_TBL.
-- =============================================================================
CREATE TABLE NON_MOTORIST_TBL (
    NMT_ID                          NUMBER(10)          GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_NMT PRIMARY KEY,
    NMT_PERSON_ID                   NUMBER(10)          NOT NULL,
    NMT_CRASH_ID                    NUMBER(10)          NOT NULL,

    -- NM1: Unit Number of Motor Vehicle Striking Non-Motorist
    NMT_STRIKING_VEHICLE_UNIT       NUMBER(3),

    -- NM2: Non-Motorist Action/Circumstance Prior to Crash
    NMT_ACTION_CIRC_CODE            NUMBER(3),
    NMT_ORIGIN_DESTINATION_CODE     NUMBER(3),

    -- NM3: Non-Motorist Contributing Actions (select 1-2, stored inline)
    NMT_CONTRIBUTING_ACTION_1       NUMBER(3),
    NMT_CONTRIBUTING_ACTION_2       NUMBER(3),

    -- NM4: Non-Motorist Location at Time of Crash
    NMT_LOCATION_AT_CRASH_CODE      NUMBER(3),

    -- NM5: Safety Equipment (multi-value 1-5) stored in NON_MOTORIST_SAFETY_EQUIPMENT_TBL

    -- NM6: Initial Contact Point on Non-Motorist
    NMT_INITIAL_CONTACT_POINT       NUMBER(3),

    -- Audit Columns
    NMT_CREATED_BY                  VARCHAR2(100)       NOT NULL,
    NMT_CREATED_DT                  DATE                DEFAULT SYSDATE NOT NULL,
    NMT_MODIFIED_BY                 VARCHAR2(100),
    NMT_MODIFIED_DT                 DATE,
    NMT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)        NOT NULL,

    CONSTRAINT UQ_NMT_PERSON_ID     UNIQUE (NMT_PERSON_ID)
);

COMMENT ON TABLE NON_MOTORIST_TBL IS 'MMUCC Non-Motorist Section NM1-NM6. One row per non-motorist per crash.';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_PERSON_ID IS 'FK to PERSON_TBL (must be non-motorist: PRS_PERSON_TYPE_CODE 4-9)';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_CRASH_ID IS 'FK to CRASH_TBL (denormalized for query convenience)';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_STRIKING_VEHICLE_UNIT IS 'NM1: Unit number (from V2 SF2) of the first motor vehicle that struck this non-motorist';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_ACTION_CIRC_CODE IS 'NM2 SF1: Action immediately prior to crash. Values: 0=None, 1=Adjacent to Roadway, 2=Crossing Roadway, 3=In Roadway Other, 4=Waiting to Cross, 5=Walking/Cycling Against Traffic, 6=Walking/Cycling With Traffic, 7=Walking/Cycling on Sidewalk, 8=Working in Trafficway, 98=Other, 99=Unknown';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_ORIGIN_DESTINATION_CODE IS 'NM2 SF2: Values: 1=Going to/from School (K-12), 2=Going to/from Transit, 97=Not Applicable, 99=Unknown';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_CONTRIBUTING_ACTION_1 IS 'NM3: Primary contributing action. Values: 0=None, 1=Dart/Dash, 2=Disabled Vehicle Related, 3=Entering/Exiting Parked Vehicle, 4=Failure to Obey Traffic Signs/Signals/Officer, 5=Failure to Yield Right-of-Way, 6=Improper Passing, 7=Improper Turn/Merge, 8=Inattentive, 9=In Roadway Improperly, 10=Not Visible, 11=Wrong-Way Riding or Walking, 98=Other, 99=Unknown';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_CONTRIBUTING_ACTION_2 IS 'NM3: Secondary contributing action. Same values as NMT_CONTRIBUTING_ACTION_1.';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_LOCATION_AT_CRASH_CODE IS 'NM4: Values: 1=Intersection Marked Crosswalk, 2=Intersection Unmarked Crosswalk, 3=Intersection Other, 4=Median/Crossing Island, 5=Midblock Marked Crosswalk, 6=Shoulder/Roadside, 7=Travel Lane Other, 8=Signed Route (no marking), 9=Shared Lane Markings, 10=On-Street Bike Lanes, 11=On-Street Buffered Bike Lanes, 12=Separated Bike Lanes, 13=Off-Street Trails/Sidepaths, 14=Driveway Access, 15=Non-Trafficway Area, 16=Shared-Use Path or Trail, 17=Sidewalk, 98=Other, 99=Unknown';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_INITIAL_CONTACT_POINT IS 'NM6: Clock-position of first contact on non-motorist body. Values: 3=Right, 6=Rear, 9=Left, 12=Front, 99=Unknown';
COMMENT ON COLUMN NON_MOTORIST_TBL.NMT_LAST_UPDATED_ACTIVITY_CODE IS 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved';

CREATE INDEX IDX_NMT_CRASH_ID ON NON_MOTORIST_TBL (NMT_CRASH_ID);

ALTER TABLE NON_MOTORIST_TBL ADD CONSTRAINT FK_NMT_PERSON
    FOREIGN KEY (NMT_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE;
ALTER TABLE NON_MOTORIST_TBL ADD CONSTRAINT FK_NMT_CRASH
    FOREIGN KEY (NMT_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE;
