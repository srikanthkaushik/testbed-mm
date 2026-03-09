-- =============================================================================
-- Table : NON_MOTORIST_TBL
-- Acronym: NMT
-- Source : MMUCC v5 Non-Motorist Section Data Elements NM1 - NM6
-- Notes : One row per non-motorist person involved in the crash.
--         Required when PERSON_TBL.PRS_PERSON_TYPE_CODE is 4-9 (non-motorist).
--         NM5 (Safety Equipment, multi-value 1-5) stored in NON_MOTORIST_SAFETY_EQUIPMENT_TBL.
-- =============================================================================
CREATE TABLE NON_MOTORIST_TBL (
    NMT_ID                          INT UNSIGNED        NOT NULL    AUTO_INCREMENT  COMMENT 'Surrogate primary key',
    NMT_PERSON_ID                   INT UNSIGNED        NOT NULL    COMMENT 'FK to PERSON_TBL (must be a non-motorist: PRS_PERSON_TYPE_CODE 4-9)',
    NMT_CRASH_ID                    INT UNSIGNED        NOT NULL    COMMENT 'FK to CRASH_TBL (denormalized for query convenience)',

    -- NM1: Unit Number of Motor Vehicle Striking Non-Motorist
    NMT_STRIKING_VEHICLE_UNIT       TINYINT UNSIGNED    NULL        COMMENT 'NM1: Unit number (from V2 SF2) of the first motor vehicle that struck this non-motorist',

    -- NM2: Non-Motorist Action/Circumstance Prior to Crash
    NMT_ACTION_CIRC_CODE            TINYINT UNSIGNED    NULL        COMMENT 'NM2 SF1: Action immediately prior to crash. Values: 0=None, 1=Adjacent to Roadway (Shoulder/Median), 2=Crossing Roadway, 3=In Roadway Other, 4=Waiting to Cross Roadway, 5=Walking/Cycling Along Roadway Against Traffic, 6=Walking/Cycling Along Roadway With Traffic, 7=Walking/Cycling on Sidewalk, 8=Working in Trafficway (Incident Response), 98=Other, 99=Unknown',
    NMT_ORIGIN_DESTINATION_CODE     TINYINT UNSIGNED    NULL        COMMENT 'NM2 SF2: Trip origin/destination. Values: 1=Going to or from School (K-12), 2=Going to or from Transit, 97=Not Applicable, 99=Unknown',

    -- NM3: Non-Motorist Contributing Actions/Circumstances (select 1-2, stored inline)
    NMT_CONTRIBUTING_ACTION_1       TINYINT UNSIGNED    NULL        COMMENT 'NM3: Primary contributing action. Values: 0=None, 1=Dart/Dash, 2=Disabled Vehicle Related, 3=Entering/Exiting Parked Vehicle, 4=Failure to Obey Traffic Signs/Signals/Officer, 5=Failure to Yield Right-of-Way, 6=Improper Passing, 7=Improper Turn/Merge, 8=Inattentive (Talking/Eating etc.), 9=In Roadway Improperly (Standing/Lying/Working/Playing), 10=Not Visible (Dark Clothing/No Lighting), 11=Wrong-Way Riding or Walking, 98=Other, 99=Unknown',
    NMT_CONTRIBUTING_ACTION_2       TINYINT UNSIGNED    NULL        COMMENT 'NM3: Secondary contributing action. Same values as NMT_CONTRIBUTING_ACTION_1.',

    -- NM4: Non-Motorist Location at Time of Crash
    NMT_LOCATION_AT_CRASH_CODE      TINYINT UNSIGNED    NULL        COMMENT 'NM4: Location at time of crash. Roadway Facility: 1=Intersection Marked Crosswalk, 2=Intersection Unmarked Crosswalk, 3=Intersection Other, 4=Median/Crossing Island, 5=Midblock Marked Crosswalk, 6=Shoulder/Roadside, 7=Travel Lane Other. Bicycle Facility: 8=Signed Route (no marking), 9=Shared Lane Markings, 10=On-Street Bike Lanes, 11=On-Street Buffered Bike Lanes, 12=Separated Bike Lanes, 13=Off-Street Trails/Sidepaths. Other: 14=Driveway Access, 15=Non-Trafficway Area, 16=Shared-Use Path or Trail, 17=Sidewalk, 98=Other, 99=Unknown',

    -- NM5: Safety Equipment (multi-value 1-5) stored in NON_MOTORIST_SAFETY_EQUIPMENT_TBL

    -- NM6: Initial Contact Point on Non-Motorist
    NMT_INITIAL_CONTACT_POINT       TINYINT UNSIGNED    NULL        COMMENT 'NM6: Clock-position of first contact on non-motorist body. Values: 3=Right, 6=Rear, 9=Left, 12=Front, 99=Unknown',

    -- Audit Columns
    NMT_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    NMT_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    NMT_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    NMT_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    NMT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (NMT_ID),
    UNIQUE KEY UQ_NMT_PERSON_ID     (NMT_PERSON_ID),
    INDEX IDX_NMT_CRASH_ID          (NMT_CRASH_ID),
    CONSTRAINT FK_NMT_PERSON FOREIGN KEY (NMT_PERSON_ID) REFERENCES PERSON_TBL (PRS_PERSON_ID) ON DELETE CASCADE,
    CONSTRAINT FK_NMT_CRASH  FOREIGN KEY (NMT_CRASH_ID)  REFERENCES CRASH_TBL  (CRS_CRASH_ID)  ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='MMUCC Non-Motorist Section NM1-NM6. One row per non-motorist per crash.';
