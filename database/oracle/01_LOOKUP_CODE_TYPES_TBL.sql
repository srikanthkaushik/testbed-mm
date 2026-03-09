-- =============================================================================
-- FILE: 01_LOOKUP_CODE_TYPES_TBL.sql
-- DESC: MMUCC v5 Lookup Code Types table.
--       Defines the categories of lookup codes, replacing 7 separate MySQL
--       reference tables (crash type, harmful event, weather condition, etc.).
-- DB:   Oracle 19c
-- =============================================================================

CREATE TABLE LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE                   VARCHAR2(30)    NOT NULL CONSTRAINT PK_LCT PRIMARY KEY,
    LCT_DESCRIPTION                 VARCHAR2(200)   NOT NULL,
    LCT_FIELD_1_DESC                VARCHAR2(100),
    LCT_FIELD_2_DESC                VARCHAR2(100),
    LCT_FIELD_3_DESC                VARCHAR2(100),
    LCT_FIELD_4_DESC                VARCHAR2(100),
    LCT_FIELD_5_DESC                VARCHAR2(100),
    LCT_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    LCT_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    LCT_MODIFIED_BY                 VARCHAR2(100),
    LCT_MODIFIED_DT                 DATE,
    LCT_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL
);

-- ---------------------------------------------------------------------------
-- Table comment
-- ---------------------------------------------------------------------------
COMMENT ON TABLE LOOKUP_CODE_TYPES_TBL IS
    'Defines the categories (types) of lookup codes used throughout the MMUCC v5 schema. Each row represents one domain of coded values (e.g., CRASH_TYPE, HARMFUL_EVENT). The FIELD_N_DESC columns describe the semantics of the corresponding FIELD_N columns in LOOKUP_CODE_VALUES_TBL for that type.';

-- ---------------------------------------------------------------------------
-- Column comments
-- ---------------------------------------------------------------------------
COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_TYPE_CODE IS
    'Primary key. Short alphanumeric code identifying the lookup domain (e.g., CRASH_TYPE, HARMFUL_EVENT).';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_DESCRIPTION IS
    'Human-readable description of this lookup type, including the relevant MMUCC data element reference.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_FIELD_1_DESC IS
    'Describes the meaning of the LCV_FIELD_1 column in LOOKUP_CODE_VALUES_TBL for values belonging to this type. NULL if FIELD_1 is not used.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_FIELD_2_DESC IS
    'Describes the meaning of the LCV_FIELD_2 column in LOOKUP_CODE_VALUES_TBL for values belonging to this type. NULL if FIELD_2 is not used.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_FIELD_3_DESC IS
    'Describes the meaning of the LCV_FIELD_3 column in LOOKUP_CODE_VALUES_TBL for values belonging to this type. NULL if FIELD_3 is not used.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_FIELD_4_DESC IS
    'Describes the meaning of the LCV_FIELD_4 column in LOOKUP_CODE_VALUES_TBL for values belonging to this type. NULL if FIELD_4 is not used.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_FIELD_5_DESC IS
    'Describes the meaning of the LCV_FIELD_5 column in LOOKUP_CODE_VALUES_TBL for values belonging to this type. NULL if FIELD_5 is not used.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_CREATED_BY IS
    'Username or process that created this row.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_CREATED_DT IS
    'Date and time this row was created. Defaults to SYSDATE.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_MODIFIED_BY IS
    'Username or process that last modified this row. NULL if never modified.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_MODIFIED_DT IS
    'Date and time this row was last modified. NULL if never modified.';

COMMENT ON COLUMN LOOKUP_CODE_TYPES_TBL.LCT_LAST_UPDATED_ACTIVITY_CODE IS
    'Code identifying the activity (e.g., IMPORT, USER_EDIT) that last updated this row.';

-- ---------------------------------------------------------------------------
-- Seed data — 7 lookup type definitions
-- ---------------------------------------------------------------------------
INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'CRASH_TYPE',
    'MMUCC C2 SF1: Crash Classification Crash Type',
    'Crash Type Description', NULL, NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'HARMFUL_EVENT',
    'MMUCC C7/V20/V21: First Harmful Event and Sequence of Events',
    'Event Description',
    'Event Category (NON_HARMFUL, NON_COLLISION_HARMFUL, COLLISION_PERSON_MV, COLLISION_FIXED)',
    NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'WEATHER_CONDITION',
    'MMUCC C11: Weather Conditions at Time of Crash',
    'Weather Condition Description', NULL, NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'SURFACE_CONDITION',
    'MMUCC C13: Roadway Surface Condition',
    'Surface Condition Description', NULL, NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'PERSON_TYPE',
    'MMUCC P4 SF1: Person Type',
    'Person Type Description',
    'Is Non-Motorist (Y=Non-Motorist section required, N=Not required)',
    NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'INJURY_STATUS',
    'MMUCC P5: Injury Status (KABCO)',
    'Injury Status Description',
    'KABCO Letter Code',
    'Requires Fatal Section (Y=Yes, N=No)',
    NULL, NULL,
    'SYSTEM', 'IMPORT'
);

INSERT INTO LOOKUP_CODE_TYPES_TBL (
    LCT_TYPE_CODE, LCT_DESCRIPTION,
    LCT_FIELD_1_DESC, LCT_FIELD_2_DESC, LCT_FIELD_3_DESC, LCT_FIELD_4_DESC, LCT_FIELD_5_DESC,
    LCT_CREATED_BY, LCT_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'BODY_TYPE',
    'MMUCC V8 SF1: Motor Vehicle Body Type Category',
    'Body Type Description',
    'Requires Large Vehicle Section (Y=Yes, N=No)',
    NULL, NULL, NULL,
    'SYSTEM', 'IMPORT'
);

COMMIT;
