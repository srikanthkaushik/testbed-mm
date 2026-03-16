-- =============================================================================
-- Test Data Seed Script — MMUCC Crash Reporting System
-- File    : seed_crashes.sql
-- Purpose : Insert realistic sample crash records so the UI has data to
--           display in the crash list and crash detail views.
-- State   : New Hampshire (FIPS state prefix 33)
-- Safety  : All test records use the prefix 'TEST-' in CRS_CRASH_IDENTIFIER.
--           The DELETE at the top removes only those rows (cascades to all
--           child tables), so this script is safe to re-run at any time.
-- Run     : mysql -u mmucc_user -p mmucc5 < seed_crashes.sql
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------------
-- Clean out any previously seeded test records (cascade deletes all children)
-- ---------------------------------------------------------------------------
DELETE FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER LIKE 'TEST-%';

SET FOREIGN_KEY_CHECKS = 1;

-- ===========================================================================
-- NH COUNTY FIPS REFERENCE
--   Belknap 33001 | Carroll 33003 | Cheshire 33005 | Coos    33007
--   Grafton 33009 | Hillsborough 33011 | Merrimack 33013 | Rockingham 33015
--   Strafford 33017 | Sullivan 33019
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- CRASH 1 — Fatal rear-end collision, I-93 southbound near Manchester
--           Hillsborough County — 1 fatality, 2 vehicles, daytime, clear
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE, CRS_ROUTE_DIRECTION_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-001', 2, 29,
    '2024-07-15', '14:23:00',
    '33011', 'Hillsborough', '3349060', 'Manchester',
    'I-93', 3, 6,
    42.9705, -71.4521,
    1, 2,
    1, 1,
    1, 1, 1,
    1,
    2, 3, 0,
    0, 1,
    2, 2, 2,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 2 — Angle collision at signalized intersection, Rockingham County
--           Portsmouth, US-1 at Woodbury Ave — 2 serious injuries, evening
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_JUNCTION_LOCATION_CODE,
    CRS_INTERSECTION_APPROACHES, CRS_INTERSECTION_GEOMETRY_CODE, CRS_INTERSECTION_TRAFFIC_CTL,
    CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-002', 4, 25,
    '2024-08-22', '18:05:00',
    '33015', 'Rockingham', '3362440', 'Portsmouth',
    'US-1', 2,
    43.0591, -70.7631,
    1, 5,
    1, 5,
    2, 5,
    4, 3, 1,
    1, 1,
    2,
    2, 4, 0,
    2, 0,
    2, 2, 5,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 3 — Single vehicle rollover, Grafton County
--           NH-16 northbound near North Conway — 3 minor injuries, rain + fog
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-003', 1, 11,
    '2024-09-10', '22:47:00',
    '33003', 'Carroll', '3314300', 'Conway',
    'NH-16', 1,
    44.0531, -71.1275,
    1, 1,
    1, 3,
    1, 1, 1,
    3,
    1, 2, 0,
    3, 0,
    2, 2, 3,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 4 — Head-on collision, Carroll County
--           US-302 through Crawford Notch — 1 fatality, 1 serious injury, dark
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE, CRS_ROUTE_DIRECTION_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-004', 3, 25,
    '2024-10-05', '02:15:00',
    '33003', 'Carroll', '3321900', 'Hart''s Location',
    'US-302', 2, 3,
    44.2167, -71.4021,
    1, 3,
    1, 2,
    1, 1, 1,
    1,
    2, 3, 0,
    1, 1,
    2, 2, 7,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 5 — PDO rear-end, F.E. Everett Turnpike (US-3), Hillsborough County
--           Near Nashua — no injuries, 2 vehicles, morning rush, daylight
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE, CRS_ROUTE_DIRECTION_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-005', 2, 29,
    '2024-11-12', '08:33:00',
    '33011', 'Hillsborough', '3358300', 'Nashua',
    'US-3', 2, 1,
    42.7724, -71.4802,
    1, 2,
    1, 1,
    1, 1, 1,
    5,
    2, 2, 0,
    0, 0,
    2, 2, 3,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 6 — Sideswipe, nighttime, Merrimack County
--           NH-9 westbound near Concord — 1 possible injury, dark-lighted
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-006', 2, 27,
    '2024-11-28', '23:11:00',
    '33013', 'Merrimack', '3318820', 'Concord',
    'NH-9', 1,
    43.2030, -71.5680,
    1, 6,
    1, 3,
    1, 1, 1,
    4,
    2, 2, 0,
    1, 0,
    2, 2, 5,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 7 — Work zone crash with pedestrian, Rockingham County
--           I-95 northbound near Hampton toll plaza — 1 serious injury
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE,
    CRS_WORK_ZONE_RELATED_CODE, CRS_WORK_ZONE_LOCATION_CODE, CRS_WORK_ZONE_TYPE_CODE,
    CRS_WORK_ZONE_WORKERS_CODE, CRS_WORK_ZONE_LAW_ENF_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-007', 2, 19,
    '2025-01-08', '07:50:00',
    '33015', 'Rockingham', '3333980', 'Hampton',
    'I-95', 3,
    42.9331, -70.8384,
    1, 5,
    1, 1,
    1, 1,
    2, 4, 1,
    2, 2,
    2,
    2, 3, 1,
    1, 0,
    2, 2, 4,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- CRASH 8 — Multi-vehicle (3+), icy/snowy conditions, Belknap County
--           NH-11 near Laconia — 2 minor injuries, winter morning, 3 vehicles
-- ---------------------------------------------------------------------------
INSERT INTO CRASH_TBL (
    CRS_CRASH_IDENTIFIER, CRS_CRASH_TYPE_CODE, CRS_FIRST_HARMFUL_EVENT_CODE,
    CRS_CRASH_DATE, CRS_CRASH_TIME,
    CRS_COUNTY_FIPS_CODE, CRS_COUNTY_NAME, CRS_CITY_PLACE_CODE, CRS_CITY_PLACE_NAME,
    CRS_ROUTE_ID, CRS_ROUTE_TYPE_CODE, CRS_ROUTE_DIRECTION_CODE,
    CRS_LATITUDE, CRS_LONGITUDE,
    CRS_LOC_FIRST_HARMFUL_EVENT, CRS_MANNER_COLLISION_CODE,
    CRS_SOURCE_OF_INFO_CODE, CRS_LIGHT_CONDITION_CODE,
    CRS_JUNCTION_INTERCHANGE_FLG, CRS_SCHOOL_BUS_RELATED_CODE, CRS_WORK_ZONE_RELATED_CODE,
    CRS_CRASH_SEVERITY_CODE,
    CRS_NUM_MOTOR_VEHICLES, CRS_NUM_MOTORISTS, CRS_NUM_NON_MOTORISTS,
    CRS_NUM_NON_FATALLY_INJURED, CRS_NUM_FATALITIES,
    CRS_ALCOHOL_INVOLVEMENT_CODE, CRS_DRUG_INVOLVEMENT_CODE, CRS_DAY_OF_WEEK_CODE,
    CRS_CREATED_BY, CRS_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    'TEST-008', 6, 29,
    '2025-02-03', '07:15:00',
    '33001', 'Belknap', '3341300', 'Laconia',
    'NH-11', 1, 3,
    43.5279, -71.4703,
    1, 2,
    1, 1,
    1, 1, 1,
    3,
    3, 5, 0,
    2, 0,
    2, 2, 2,
    'seed_script', 'IMPORT'
);

-- ===========================================================================
-- VEHICLES
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- Vehicles for TEST-001 (fatal rear-end, I-93 near Manchester)
-- ---------------------------------------------------------------------------
INSERT INTO VEHICLE_TBL (
    VEH_CRASH_ID, VEH_VIN, VEH_UNIT_TYPE_CODE, VEH_UNIT_NUMBER,
    VEH_REGISTRATION_STATE, VEH_REGISTRATION_YEAR, VEH_LICENSE_PLATE,
    VEH_MAKE, VEH_MODEL_YEAR, VEH_MODEL, VEH_BODY_TYPE_CODE,
    VEH_VEHICLE_SIZE_CODE, VEH_HM_PLACARD_FLG, VEH_TOTAL_OCCUPANTS,
    VEH_SPEED_LIMIT_MPH, VEH_DIRECTION_OF_TRAVEL_CODE,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE, VEH_TRAFFICWAY_DIVIDED_CODE,
    VEH_TOTAL_THROUGH_LANES, VEH_ROADWAY_ALIGNMENT_CODE, VEH_ROADWAY_GRADE_CODE,
    VEH_MANEUVER_CODE, VEH_DAMAGE_INITIAL_CONTACT, VEH_DAMAGE_EXTENT_CODE,
    VEH_MOST_HARMFUL_EVENT_CODE, VEH_HIT_AND_RUN_CODE, VEH_TOWED_CODE,
    VEH_CONTRIBUTING_CIRC_CODE,
    VEH_CREATED_BY, VEH_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    '1HGBH41JXMN109186', 1, 1,
    'NH', 2019, '4663991',
    'Honda', 2019, 'Accord', 4,
    1, 1, 1,
    65, 6,
    1, 3,
    3, 1, 1,
    6, 12, 3,
    29, 1, 2,
    0,
    'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    '2T1BURHE0JC014827', 1, 2,
    'NH', 2021, '4882107',
    'Toyota', 2021, 'Camry', 4,
    1, 1, 2,
    65, 6,
    1, 3,
    3, 1, 1,
    11, 1, 3,
    29, 1, 2,
    0,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- Vehicles for TEST-002 (angle collision, Portsmouth US-1)
-- ---------------------------------------------------------------------------
INSERT INTO VEHICLE_TBL (
    VEH_CRASH_ID, VEH_UNIT_TYPE_CODE, VEH_UNIT_NUMBER,
    VEH_REGISTRATION_STATE, VEH_REGISTRATION_YEAR, VEH_LICENSE_PLATE,
    VEH_MAKE, VEH_MODEL_YEAR, VEH_MODEL, VEH_BODY_TYPE_CODE,
    VEH_VEHICLE_SIZE_CODE, VEH_HM_PLACARD_FLG, VEH_TOTAL_OCCUPANTS,
    VEH_SPEED_LIMIT_MPH, VEH_DIRECTION_OF_TRAVEL_CODE,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE, VEH_TOTAL_THROUGH_LANES,
    VEH_ROADWAY_ALIGNMENT_CODE, VEH_ROADWAY_GRADE_CODE,
    VEH_MANEUVER_CODE, VEH_DAMAGE_INITIAL_CONTACT, VEH_DAMAGE_EXTENT_CODE,
    VEH_MOST_HARMFUL_EVENT_CODE, VEH_HIT_AND_RUN_CODE, VEH_TOWED_CODE,
    VEH_CREATED_BY, VEH_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-002'),
    1, 1,
    'NH', 2020, '3917452',
    'Ford', 2020, 'F-150', 19,
    1, 1, 2,
    35, 1,
    2, 2,
    1, 1,
    13, 9, 3,
    25, 1, 2,
    'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-002'),
    1, 2,
    'NH', 2022, '5024816',
    'Chevrolet', 2022, 'Malibu', 4,
    1, 1, 2,
    35, 6,
    2, 2,
    1, 1,
    12, 3, 3,
    25, 1, 2,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- Vehicle for TEST-003 (single vehicle rollover, NH-16 Conway)
-- ---------------------------------------------------------------------------
INSERT INTO VEHICLE_TBL (
    VEH_CRASH_ID, VEH_VIN, VEH_UNIT_TYPE_CODE, VEH_UNIT_NUMBER,
    VEH_REGISTRATION_STATE, VEH_REGISTRATION_YEAR, VEH_LICENSE_PLATE,
    VEH_MAKE, VEH_MODEL_YEAR, VEH_MODEL, VEH_BODY_TYPE_CODE,
    VEH_VEHICLE_SIZE_CODE, VEH_HM_PLACARD_FLG, VEH_TOTAL_OCCUPANTS,
    VEH_SPEED_LIMIT_MPH, VEH_DIRECTION_OF_TRAVEL_CODE,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE, VEH_TRAFFICWAY_DIVIDED_CODE,
    VEH_TOTAL_THROUGH_LANES, VEH_ROADWAY_ALIGNMENT_CODE, VEH_ROADWAY_GRADE_CODE,
    VEH_MANEUVER_CODE, VEH_DAMAGE_INITIAL_CONTACT, VEH_DAMAGE_EXTENT_CODE,
    VEH_MOST_HARMFUL_EVENT_CODE, VEH_HIT_AND_RUN_CODE, VEH_TOWED_CODE,
    VEH_CREATED_BY, VEH_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    '5UXWX9C55E0D19282', 1, 1,
    'NH', 2018, '2741039',
    'Subaru', 2018, 'Outback', 20,
    1, 1, 3,
    45, 1,
    1, 2,
    2, 2, 4,
    7, 0, 3,
    11, 1, 2,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- Vehicles for TEST-005 (PDO rear-end, US-3 Everett Turnpike near Nashua)
-- ---------------------------------------------------------------------------
INSERT INTO VEHICLE_TBL (
    VEH_CRASH_ID, VEH_UNIT_TYPE_CODE, VEH_UNIT_NUMBER,
    VEH_REGISTRATION_STATE, VEH_REGISTRATION_YEAR, VEH_LICENSE_PLATE,
    VEH_MAKE, VEH_MODEL_YEAR, VEH_MODEL, VEH_BODY_TYPE_CODE,
    VEH_VEHICLE_SIZE_CODE, VEH_HM_PLACARD_FLG, VEH_TOTAL_OCCUPANTS,
    VEH_SPEED_LIMIT_MPH, VEH_DIRECTION_OF_TRAVEL_CODE,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE, VEH_TRAFFICWAY_DIVIDED_CODE,
    VEH_TOTAL_THROUGH_LANES, VEH_ROADWAY_ALIGNMENT_CODE, VEH_ROADWAY_GRADE_CODE,
    VEH_MANEUVER_CODE, VEH_DAMAGE_INITIAL_CONTACT, VEH_DAMAGE_EXTENT_CODE,
    VEH_MOST_HARMFUL_EVENT_CODE, VEH_HIT_AND_RUN_CODE, VEH_TOWED_CODE,
    VEH_CREATED_BY, VEH_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-005'),
    1, 1,
    'NH', 2023, '5113774',
    'Jeep', 2023, 'Grand Cherokee', 20,
    1, 1, 1,
    65, 1,
    1, 3,
    3, 1, 1,
    6, 6, 1,
    29, 1, 1,
    'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-005'),
    1, 2,
    'NH', 2021, '4730562',
    'Nissan', 2021, 'Altima', 4,
    1, 1, 1,
    65, 1,
    1, 3,
    3, 1, 1,
    10, 12, 1,
    29, 1, 0,
    'seed_script', 'IMPORT'
);

-- ---------------------------------------------------------------------------
-- Vehicles for TEST-008 (3-vehicle chain, NH-11 Laconia, icy)
-- ---------------------------------------------------------------------------
INSERT INTO VEHICLE_TBL (
    VEH_CRASH_ID, VEH_UNIT_TYPE_CODE, VEH_UNIT_NUMBER,
    VEH_REGISTRATION_STATE, VEH_REGISTRATION_YEAR, VEH_LICENSE_PLATE,
    VEH_MAKE, VEH_MODEL_YEAR, VEH_MODEL, VEH_BODY_TYPE_CODE,
    VEH_VEHICLE_SIZE_CODE, VEH_HM_PLACARD_FLG, VEH_TOTAL_OCCUPANTS,
    VEH_SPEED_LIMIT_MPH, VEH_DIRECTION_OF_TRAVEL_CODE,
    VEH_TRAFFICWAY_TRAVEL_DIR_CODE, VEH_TRAFFICWAY_DIVIDED_CODE,
    VEH_TOTAL_THROUGH_LANES, VEH_ROADWAY_ALIGNMENT_CODE, VEH_ROADWAY_GRADE_CODE,
    VEH_MANEUVER_CODE, VEH_DAMAGE_INITIAL_CONTACT, VEH_DAMAGE_EXTENT_CODE,
    VEH_MOST_HARMFUL_EVENT_CODE, VEH_HIT_AND_RUN_CODE, VEH_TOWED_CODE,
    VEH_CREATED_BY, VEH_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    1, 1,
    'NH', 2020, '3806291',
    'Dodge', 2020, 'Ram 1500', 19,
    1, 1, 2,
    45, 3,
    2, 0,
    2, 1, 1,
    10, 6, 2,
    29, 1, 2,
    'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    1, 2,
    'NH', 2019, '3541887',
    'Hyundai', 2019, 'Elantra', 4,
    1, 1, 2,
    45, 3,
    2, 0,
    2, 1, 1,
    11, 6, 2,
    29, 1, 2,
    'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    1, 3,
    'NH', 2022, '4991345',
    'Kia', 2022, 'Sportage', 20,
    1, 1, 1,
    45, 3,
    2, 0,
    2, 1, 1,
    6, 1, 1,
    29, 1, 0,
    'seed_script', 'IMPORT'
);

-- ===========================================================================
-- ROADWAY DATA
-- ===========================================================================

-- TEST-001: I-93 near Manchester — NHS interstate, divided, lighted
INSERT INTO ROADWAY_TBL (
    RWY_CRASH_ID,
    RWY_NATIONAL_HWY_SYS_CODE, RWY_FUNCTIONAL_CLASS_CODE,
    RWY_AADT_YEAR, RWY_AADT_VALUE, RWY_AADT_TRUCK_MEASURE,
    RWY_LANE_WIDTH_FT, RWY_LEFT_SHOULDER_WIDTH_FT, RWY_RIGHT_SHOULDER_WIDTH_FT,
    RWY_MEDIAN_WIDTH_FT, RWY_ACCESS_CONTROL_CODE,
    RWY_ROADWAY_LIGHTING_CODE,
    RWY_PAVEMENT_EDGELINE_CODE, RWY_PAVEMENT_CENTERLINE_CODE, RWY_PAVEMENT_LANE_LINE_CODE,
    RWY_MAINLINE_LANES_COUNT,
    RWY_CREATED_BY, RWY_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    2, 9,
    2023, 74000, '11%',
    12.0, 10.0, 10.0,
    60.0, 3,
    1,
    2, 3, 2,
    3,
    'seed_script', 'IMPORT'
);

-- TEST-002: US-1, Portsmouth — urban principal arterial, signalized intersection
INSERT INTO ROADWAY_TBL (
    RWY_CRASH_ID,
    RWY_NATIONAL_HWY_SYS_CODE, RWY_FUNCTIONAL_CLASS_CODE,
    RWY_AADT_YEAR, RWY_AADT_VALUE, RWY_AADT_TRUCK_MEASURE,
    RWY_LANE_WIDTH_FT, RWY_RIGHT_SHOULDER_WIDTH_FT,
    RWY_ACCESS_CONTROL_CODE,
    RWY_ROADWAY_LIGHTING_CODE,
    RWY_PAVEMENT_EDGELINE_CODE, RWY_PAVEMENT_CENTERLINE_CODE, RWY_PAVEMENT_LANE_LINE_CODE,
    RWY_MAINLINE_LANES_COUNT, RWY_CROSS_STREET_LANES_COUNT,
    RWY_ENTERING_VEHICLES_YEAR, RWY_ENTERING_VEHICLES_AADT,
    RWY_CREATED_BY, RWY_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-002'),
    1, 11,
    2023, 24500, '4%',
    11.0, 4.0,
    1,
    1,
    2, 3, 2,
    3, 2,
    2023, 19800,
    'seed_script', 'IMPORT'
);

-- TEST-003: NH-16, Conway — rural principal arterial, curved mountain road
INSERT INTO ROADWAY_TBL (
    RWY_CRASH_ID,
    RWY_NATIONAL_HWY_SYS_CODE, RWY_FUNCTIONAL_CLASS_CODE,
    RWY_AADT_YEAR, RWY_AADT_VALUE,
    RWY_CURVE_RADIUS_FT, RWY_CURVE_LENGTH_FT,
    RWY_GRADE_DIRECTION, RWY_GRADE_PERCENT,
    RWY_LANE_WIDTH_FT, RWY_RIGHT_SHOULDER_WIDTH_FT,
    RWY_ACCESS_CONTROL_CODE,
    RWY_ROADWAY_LIGHTING_CODE,
    RWY_PAVEMENT_EDGELINE_CODE, RWY_PAVEMENT_CENTERLINE_CODE,
    RWY_CREATED_BY, RWY_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    1, 3,
    2022, 17200,
    900.0, 400.0,
    '+', 3.80,
    11.0, 4.0,
    1,
    3,
    2, 3,
    'seed_script', 'IMPORT'
);

-- TEST-008: NH-11, Laconia — urban minor arterial, winter conditions
INSERT INTO ROADWAY_TBL (
    RWY_CRASH_ID,
    RWY_NATIONAL_HWY_SYS_CODE, RWY_FUNCTIONAL_CLASS_CODE,
    RWY_AADT_YEAR, RWY_AADT_VALUE, RWY_AADT_TRUCK_MEASURE,
    RWY_LANE_WIDTH_FT, RWY_RIGHT_SHOULDER_WIDTH_FT,
    RWY_MEDIAN_WIDTH_FT, RWY_ACCESS_CONTROL_CODE,
    RWY_ROADWAY_LIGHTING_CODE,
    RWY_PAVEMENT_EDGELINE_CODE, RWY_PAVEMENT_CENTERLINE_CODE, RWY_PAVEMENT_LANE_LINE_CODE,
    RWY_MAINLINE_LANES_COUNT,
    RWY_CREATED_BY, RWY_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    1, 12,
    2023, 18400, '6%',
    11.0, 4.0,
    12.0, 1,
    2,
    2, 3, 2,
    2,
    'seed_script', 'IMPORT'
);

-- ===========================================================================
-- WEATHER CONDITIONS
-- ===========================================================================

-- TEST-003: Rain (code 3) + Fog (code 5) — White Mountains night conditions
INSERT INTO CRASH_WEATHER_CONDITION_TBL (
    CWC_CRASH_ID, CWC_SEQUENCE_NUM, CWC_WEATHER_CODE,
    CWC_CREATED_BY, CWC_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    1, 3, 'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    2, 5, 'seed_script', 'IMPORT'
);

-- TEST-008: Snow (code 4) + Blowing Snow (code 7) — Lake Winnipesaukee region winter
INSERT INTO CRASH_WEATHER_CONDITION_TBL (
    CWC_CRASH_ID, CWC_SEQUENCE_NUM, CWC_WEATHER_CODE,
    CWC_CREATED_BY, CWC_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    1, 4, 'seed_script', 'IMPORT'
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-008'),
    2, 7, 'seed_script', 'IMPORT'
);

-- Clear / cloudy weather for TEST-001 and TEST-002
INSERT INTO CRASH_WEATHER_CONDITION_TBL (
    CWC_CRASH_ID, CWC_SEQUENCE_NUM, CWC_WEATHER_CODE,
    CWC_CREATED_BY, CWC_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    1, 1, 'seed_script', 'IMPORT'    -- Clear
),
(
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-002'),
    1, 2, 'seed_script', 'IMPORT'    -- Cloudy
);

-- ===========================================================================
-- VEHICLE SEQUENCE EVENTS
-- ===========================================================================

-- TEST-001 Unit 1 (Honda Accord): collided with Unit 2 from behind
INSERT INTO VEHICLE_SEQUENCE_EVENT_TBL (
    VSE_VEHICLE_ID, VSE_CRASH_ID, VSE_SEQUENCE_NUM, VSE_EVENT_CODE,
    VSE_CREATED_BY, VSE_LAST_UPDATED_ACTIVITY_CODE
) VALUES (
    (SELECT VEH_VEHICLE_ID FROM VEHICLE_TBL
     WHERE VEH_CRASH_ID = (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001')
       AND VEH_UNIT_NUMBER = 1),
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    1, 29, 'seed_script', 'IMPORT'
);

-- TEST-001 Unit 2 (Toyota Camry): struck from behind, then hit guardrail (event 38)
INSERT INTO VEHICLE_SEQUENCE_EVENT_TBL (
    VSE_VEHICLE_ID, VSE_CRASH_ID, VSE_SEQUENCE_NUM, VSE_EVENT_CODE,
    VSE_CREATED_BY, VSE_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT VEH_VEHICLE_ID FROM VEHICLE_TBL
     WHERE VEH_CRASH_ID = (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001')
       AND VEH_UNIT_NUMBER = 2),
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    1, 29, 'seed_script', 'IMPORT'
),
(
    (SELECT VEH_VEHICLE_ID FROM VEHICLE_TBL
     WHERE VEH_CRASH_ID = (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001')
       AND VEH_UNIT_NUMBER = 2),
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-001'),
    2, 34, 'seed_script', 'IMPORT'    -- event 34 = guardrail
);

-- TEST-003 Unit 1 (Subaru Outback): lost control on wet mountain curve, rolled over
INSERT INTO VEHICLE_SEQUENCE_EVENT_TBL (
    VSE_VEHICLE_ID, VSE_CRASH_ID, VSE_SEQUENCE_NUM, VSE_EVENT_CODE,
    VSE_CREATED_BY, VSE_LAST_UPDATED_ACTIVITY_CODE
) VALUES
(
    (SELECT VEH_VEHICLE_ID FROM VEHICLE_TBL
     WHERE VEH_CRASH_ID = (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003')
       AND VEH_UNIT_NUMBER = 1),
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    1, 6, 'seed_script', 'IMPORT'    -- event 6 = ran off road
),
(
    (SELECT VEH_VEHICLE_ID FROM VEHICLE_TBL
     WHERE VEH_CRASH_ID = (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003')
       AND VEH_UNIT_NUMBER = 1),
    (SELECT CRS_CRASH_ID FROM CRASH_TBL WHERE CRS_CRASH_IDENTIFIER = 'TEST-003'),
    2, 11, 'seed_script', 'IMPORT'    -- event 11 = rollover
);

-- ===========================================================================
-- SURFACE CONDITIONS
-- ===========================================================================

-- TEST-008: Ice (code 4) — NH-11 Laconia February morning
INSERT INTO CRASH_SURFACE_CONDITION_TBL (
    CSC_CRASH_ID, CSC_SEQUENCE_NUM, CSC_SURFACE_CODE,
    CSC_CREATED_BY, CSC_LAST_UPDATED_ACTIVITY_CODE
)
SELECT CRS_CRASH_ID, 1, 4, 'seed_script', 'IMPORT'
FROM CRASH_TBL
WHERE CRS_CRASH_IDENTIFIER = 'TEST-008';

-- TEST-003: Wet (code 2) — NH-16 Conway after rain
INSERT INTO CRASH_SURFACE_CONDITION_TBL (
    CSC_CRASH_ID, CSC_SEQUENCE_NUM, CSC_SURFACE_CODE,
    CSC_CREATED_BY, CSC_LAST_UPDATED_ACTIVITY_CODE
)
SELECT CRS_CRASH_ID, 1, 2, 'seed_script', 'IMPORT'
FROM CRASH_TBL
WHERE CRS_CRASH_IDENTIFIER = 'TEST-003';

-- ===========================================================================
-- VERIFICATION QUERIES (run these after the script to confirm)
-- ===========================================================================
-- SELECT CRS_CRASH_IDENTIFIER, CRS_CRASH_DATE, CRS_COUNTY_NAME, CRS_CITY_PLACE_NAME,
--        CRS_CRASH_SEVERITY_CODE, CRS_NUM_MOTOR_VEHICLES, CRS_NUM_FATALITIES
-- FROM CRASH_TBL
-- WHERE CRS_CRASH_IDENTIFIER LIKE 'TEST-%'
-- ORDER BY CRS_CRASH_DATE;
--
-- SELECT c.CRS_CRASH_IDENTIFIER, COUNT(v.VEH_VEHICLE_ID) AS vehicle_count
-- FROM CRASH_TBL c
-- LEFT JOIN VEHICLE_TBL v ON v.VEH_CRASH_ID = c.CRS_CRASH_ID
-- WHERE c.CRS_CRASH_IDENTIFIER LIKE 'TEST-%'
-- GROUP BY c.CRS_CRASH_IDENTIFIER;
