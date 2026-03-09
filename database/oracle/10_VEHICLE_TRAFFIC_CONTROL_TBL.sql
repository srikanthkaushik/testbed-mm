-- =============================================================================
-- FILE:    10_VEHICLE_TRAFFIC_CONTROL_TBL.sql
-- PURPOSE: MMUCC V17 Traffic Control Device — multi-value child table
-- DBMS:    Oracle 19c
-- ACRONYM: VTC
-- =============================================================================

CREATE TABLE VEHICLE_TRAFFIC_CONTROL_TBL (
    VTC_ID                            NUMBER GENERATED ALWAYS AS IDENTITY CONSTRAINT PK_VTC PRIMARY KEY,
    VTC_VEHICLE_ID                    NUMBER(10)      NOT NULL,
    VTC_CRASH_ID                      NUMBER(10)      NOT NULL,
    VTC_SEQUENCE_NUM                  NUMBER(3)       NOT NULL,
    VTC_TRAFFIC_CONTROL_CODE          NUMBER(3)       NOT NULL,
    VTC_DEVICE_INOPERATIVE_CODE       NUMBER(3),
    -- Audit Columns
    VTC_CREATED_BY                    VARCHAR2(100)   NOT NULL,
    VTC_CREATED_DT                    DATE            DEFAULT SYSDATE NOT NULL,
    VTC_MODIFIED_BY                   VARCHAR2(100),
    VTC_MODIFIED_DT                   DATE,
    VTC_LAST_UPDATED_ACTIVITY_CODE    VARCHAR2(20)    NOT NULL,
    -- Table Constraints
    CONSTRAINT UQ_VTC_VEH_SEQ UNIQUE (VTC_VEHICLE_ID, VTC_SEQUENCE_NUM)
);

-- -----------------------------------------------------------------------------
-- Table Comment
-- -----------------------------------------------------------------------------
COMMENT ON TABLE VEHICLE_TRAFFIC_CONTROL_TBL IS 'MMUCC V17 Traffic Control Device. Multi-value child table — up to 4 traffic control devices per vehicle per crash.';

-- -----------------------------------------------------------------------------
-- Column Comments
-- -----------------------------------------------------------------------------
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_ID                           IS 'Surrogate primary key for vehicle traffic control record.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_VEHICLE_ID                   IS 'FK to VEHICLE_TBL. Identifies the vehicle this traffic control device applies to.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_CRASH_ID                     IS 'FK to CRASH_TBL. Denormalized crash reference for efficient crash-level queries.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_SEQUENCE_NUM                 IS 'Entry sequence number (1-4). Indicates the order of multiple traffic control devices recorded for a vehicle.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_TRAFFIC_CONTROL_CODE         IS 'V17 SF1: Type of traffic control device present. 0=No Controls, 1=Traffic Signal, 2=Traffic Signal with Pedestrian Signal, 3=Flashing Traffic Signal, 4=Stop Sign, 5=Yield Sign, 6=Warning Sign, 7=Railroad Crossing Device Active, 8=Railroad Crossing Device Passive, 9=School Zone Sign, 10=No Passing Zone Sign, 11=Bike Lane Sign, 12=Center Line Pavement Marking, 13=Lane Line Pavement Marking, 14=Edge Line Pavement Marking, 15=Raised Pavement Marker, 16=Speed Feedback Sign, 98=Other, 99=Unknown.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_DEVICE_INOPERATIVE_CODE      IS 'V17 SF2: Indicates if the traffic control device was functioning. 1=No (Functioning), 2=Yes (Not Functioning), 97=Not Applicable, 99=Unknown.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_CREATED_BY                   IS 'Audit: User or process that created the record.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_CREATED_DT                   IS 'Audit: Date and time the record was created.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_MODIFIED_BY                  IS 'Audit: User or process that last modified the record.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_MODIFIED_DT                  IS 'Audit: Date and time the record was last modified.';
COMMENT ON COLUMN VEHICLE_TRAFFIC_CONTROL_TBL.VTC_LAST_UPDATED_ACTIVITY_CODE   IS 'Audit: Activity code of the last update operation (e.g., INSERT, UPDATE, IMPORT).';

-- -----------------------------------------------------------------------------
-- Indexes
-- -----------------------------------------------------------------------------
CREATE INDEX IDX_VTC_VEHICLE_ID ON VEHICLE_TRAFFIC_CONTROL_TBL (VTC_VEHICLE_ID);
CREATE INDEX IDX_VTC_CRASH_ID   ON VEHICLE_TRAFFIC_CONTROL_TBL (VTC_CRASH_ID);

-- -----------------------------------------------------------------------------
-- Foreign Key Constraints
-- -----------------------------------------------------------------------------
ALTER TABLE VEHICLE_TRAFFIC_CONTROL_TBL
    ADD CONSTRAINT FK_VTC_VEHICLE
    FOREIGN KEY (VTC_VEHICLE_ID)
    REFERENCES VEHICLE_TBL (VEH_VEHICLE_ID)
    ON DELETE CASCADE;

ALTER TABLE VEHICLE_TRAFFIC_CONTROL_TBL
    ADD CONSTRAINT FK_VTC_CRASH
    FOREIGN KEY (VTC_CRASH_ID)
    REFERENCES CRASH_TBL (CRS_CRASH_ID)
    ON DELETE CASCADE;
