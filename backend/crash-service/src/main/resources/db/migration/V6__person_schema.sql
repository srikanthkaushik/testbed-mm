-- =============================================================================
-- V6__person_schema.sql  (idempotent)
-- Adds Person, Fatal, Non-Motorist, Large Vehicle, and Vehicle Automation
-- data columns to the stub tables created in V1.
--
-- Uses a stored-procedure helper to guard every ADD COLUMN with an
-- information_schema check so this migration is safe whether the columns
-- already exist (live mmucc5 DB built from the original DDL scripts) or not
-- (fresh Testcontainers instance that only has V1 stub columns).
-- =============================================================================

DELIMITER $$

-- ── Helper: add a column only if it does not already exist ────────────────────
DROP PROCEDURE IF EXISTS _mmucc_add_col$$
CREATE PROCEDURE _mmucc_add_col(p_tbl VARCHAR(64), p_col VARCHAR(64), p_def TEXT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_tbl
          AND COLUMN_NAME  = p_col
    ) THEN
        SET @_sql = CONCAT('ALTER TABLE `', p_tbl, '` ADD COLUMN `', p_col, '` ', p_def);
        PREPARE _st FROM @_sql;
        EXECUTE _st;
        DEALLOCATE PREPARE _st;
    END IF;
END$$

-- ── Helper: create an index only if it does not already exist ─────────────────
DROP PROCEDURE IF EXISTS _mmucc_add_idx$$
CREATE PROCEDURE _mmucc_add_idx(p_tbl VARCHAR(64), p_idx VARCHAR(64), p_cols TEXT)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME   = p_tbl
          AND INDEX_NAME   = p_idx
    ) THEN
        SET @_sql = CONCAT('CREATE INDEX `', p_idx, '` ON `', p_tbl, '` (', p_cols, ')');
        PREPARE _st FROM @_sql;
        EXECUTE _st;
        DEALLOCATE PREPARE _st;
    END IF;
END$$

DELIMITER ;

-- =============================================================================
-- PERSON_TBL  — P1–P27 data columns
-- =============================================================================
CALL _mmucc_add_col('PERSON_TBL', 'PRS_PERSON_NAME',              'VARCHAR(150) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DOB_YEAR',                 'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DOB_MONTH',                'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DOB_DAY',                  'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_AGE_YEARS',                'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_SEX_CODE',                 'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_PERSON_TYPE_CODE',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_INCIDENT_RESPONDER_CODE',  'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_INJURY_STATUS_CODE',       'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_VEHICLE_UNIT_NUMBER',      'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_SEATING_ROW_CODE',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_SEATING_SEAT_CODE',        'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_RESTRAINT_CODE',           'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_RESTRAINT_IMPROPER_FLG',   'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_EJECTION_CODE',            'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_JURISDICTION_TYPE',     'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_JURISDICTION_CODE',     'VARCHAR(10) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_NUMBER',                'VARCHAR(30) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_CLASS_CODE',            'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_IS_CDL_FLG',            'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_ENDORSEMENT_CODE',      'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_SPEEDING_CODE',            'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_VIOLATION_CODE_1',         'VARCHAR(20) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_VIOLATION_CODE_2',         'VARCHAR(20) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_ALCOHOL_INTERLOCK_FLG', 'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_STATUS_TYPE_CODE',      'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DL_STATUS_CODE',           'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DISTRACTED_ACTION_CODE',   'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DISTRACTED_SOURCE_CODE',   'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_CONDITION_CODE_1',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_CONDITION_CODE_2',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_LE_SUSPECTS_ALCOHOL',      'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_ALCOHOL_TEST_STATUS_CODE', 'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_ALCOHOL_TEST_TYPE_CODE',   'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_ALCOHOL_BAC_RESULT',       'VARCHAR(10) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_LE_SUSPECTS_DRUG',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DRUG_TEST_STATUS_CODE',    'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_DRUG_TEST_TYPE_CODE',      'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_TRANSPORT_SOURCE_CODE',    'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_EMS_AGENCY_ID',            'VARCHAR(50) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_EMS_RUN_NUMBER',           'VARCHAR(50) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_MEDICAL_FACILITY',         'VARCHAR(100) NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_INJURY_AREA_CODE',         'INT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_INJURY_DIAGNOSIS',         'TEXT NULL');
CALL _mmucc_add_col('PERSON_TBL', 'PRS_INJURY_SEVERITY_CODE',     'INT NULL');

CALL _mmucc_add_idx('PERSON_TBL', 'IDX_PERSON_VEHICLE_ID', 'PRS_VEHICLE_ID');
CALL _mmucc_add_idx('PERSON_TBL', 'IDX_PERSON_CRASH_ID',   'PRS_CRASH_ID');

-- =============================================================================
-- PERSON_AIRBAG_TBL
-- =============================================================================
CALL _mmucc_add_col('PERSON_AIRBAG_TBL', 'PAB_SEQUENCE_NUM', 'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('PERSON_AIRBAG_TBL', 'PAB_AIRBAG_CODE',  'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- PERSON_DRIVER_ACTION_TBL
-- =============================================================================
CALL _mmucc_add_col('PERSON_DRIVER_ACTION_TBL', 'PDA_SEQUENCE_NUM', 'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('PERSON_DRIVER_ACTION_TBL', 'PDA_ACTION_CODE',  'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- PERSON_DL_RESTRICTION_TBL
-- =============================================================================
CALL _mmucc_add_col('PERSON_DL_RESTRICTION_TBL', 'PDR_SEQUENCE_NUM',     'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('PERSON_DL_RESTRICTION_TBL', 'PDR_RESTRICTION_CODE', 'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- PERSON_DRUG_TEST_RESULT_TBL
-- =============================================================================
CALL _mmucc_add_col('PERSON_DRUG_TEST_RESULT_TBL', 'DTR_SEQUENCE_NUM', 'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('PERSON_DRUG_TEST_RESULT_TBL', 'DTR_RESULT_CODE',  'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- FATAL_SECTION_TBL  — F1–F3
-- =============================================================================
CALL _mmucc_add_col('FATAL_SECTION_TBL', 'FSC_AVOIDANCE_MANEUVER_CODE', 'INT NULL');
CALL _mmucc_add_col('FATAL_SECTION_TBL', 'FSC_ALCOHOL_TEST_TYPE_CODE',  'INT NULL');
CALL _mmucc_add_col('FATAL_SECTION_TBL', 'FSC_ALCOHOL_TEST_RESULT',     'VARCHAR(10) NULL');
CALL _mmucc_add_col('FATAL_SECTION_TBL', 'FSC_DRUG_TEST_TYPE_CODE',     'INT NULL');
CALL _mmucc_add_col('FATAL_SECTION_TBL', 'FSC_DRUG_TEST_RESULT',        'INT NULL');

-- =============================================================================
-- NON_MOTORIST_TBL  — NM1–NM6
-- =============================================================================
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_STRIKING_VEHICLE_UNIT',   'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_ACTION_CIRC_CODE',        'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_ORIGIN_DESTINATION_CODE', 'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_CONTRIBUTING_ACTION_1',   'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_CONTRIBUTING_ACTION_2',   'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_LOCATION_AT_CRASH_CODE',  'INT NULL');
CALL _mmucc_add_col('NON_MOTORIST_TBL', 'NMT_INITIAL_CONTACT_POINT',   'INT NULL');

-- =============================================================================
-- NON_MOTORIST_SAFETY_EQUIPMENT_TBL
-- =============================================================================
CALL _mmucc_add_col('NON_MOTORIST_SAFETY_EQUIPMENT_TBL', 'NMS_SEQUENCE_NUM',   'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('NON_MOTORIST_SAFETY_EQUIPMENT_TBL', 'NMS_EQUIPMENT_CODE', 'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- LARGE_VEHICLE_TBL  — LV1–LV11
-- =============================================================================
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CMV_LICENSE_STATUS_CODE', 'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CDL_COMPLIANCE_CODE',     'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER1_PLATE',          'VARCHAR(20) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER2_PLATE',          'VARCHAR(20) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER3_PLATE',          'VARCHAR(20) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER1_VIN',            'VARCHAR(17) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER2_VIN',            'VARCHAR(17) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER3_VIN',            'VARCHAR(17) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER1_MAKE',           'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER2_MAKE',           'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER3_MAKE',           'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER1_MODEL',          'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER2_MODEL',          'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER3_MODEL',          'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER1_YEAR',           'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER2_YEAR',           'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_TRAILER3_YEAR',           'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_ID_TYPE_CODE',    'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_COUNTRY_STATE',   'VARCHAR(10) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_ID_NUMBER',       'VARCHAR(20) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_NAME',            'VARCHAR(150) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_STREET1',         'VARCHAR(100) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_STREET2',         'VARCHAR(100) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_CITY',            'VARCHAR(100) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_STATE',           'VARCHAR(10) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_ZIP',             'VARCHAR(20) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_COUNTRY',         'VARCHAR(50) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARRIER_TYPE_CODE',       'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_VEHICLE_CONFIG_CODE',     'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_VEHICLE_PERMITTED_CODE',  'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_CARGO_BODY_TYPE_CODE',    'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_HM_ID',                   'VARCHAR(10) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_HM_CLASS',                'VARCHAR(5) NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_HM_RELEASED_CODE',        'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_AXLES_TRACTOR',           'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_AXLES_TRAILER1',          'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_AXLES_TRAILER2',          'INT NULL');
CALL _mmucc_add_col('LARGE_VEHICLE_TBL', 'LVH_AXLES_TRAILER3',          'INT NULL');

-- =============================================================================
-- LV_SPECIAL_SIZING_TBL
-- =============================================================================
CALL _mmucc_add_col('LV_SPECIAL_SIZING_TBL', 'LVS_SEQUENCE_NUM', 'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('LV_SPECIAL_SIZING_TBL', 'LVS_SIZING_CODE',  'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- VEHICLE_AUTOMATION_TBL  — DV1
-- =============================================================================
CALL _mmucc_add_col('VEHICLE_AUTOMATION_TBL', 'VAT_AUTOMATION_PRESENT_CODE', 'INT NULL');

-- =============================================================================
-- VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL
-- =============================================================================
CALL _mmucc_add_col('VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL', 'VAI_SEQUENCE_NUM',          'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL', 'VAI_AUTOMATION_LEVEL_CODE', 'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL
-- =============================================================================
CALL _mmucc_add_col('VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL', 'VAE_SEQUENCE_NUM',          'INT NOT NULL DEFAULT 1');
CALL _mmucc_add_col('VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL', 'VAE_AUTOMATION_LEVEL_CODE', 'INT NOT NULL DEFAULT 0');

-- =============================================================================
-- Cleanup helpers
-- =============================================================================
DROP PROCEDURE IF EXISTS _mmucc_add_col;
DROP PROCEDURE IF EXISTS _mmucc_add_idx;
