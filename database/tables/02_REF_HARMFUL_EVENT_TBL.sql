-- =============================================================================
-- Table : REF_HARMFUL_EVENT_TBL
-- Acronym: RHE
-- Source : MMUCC v5 C7, V20, V21 - First Harmful Event / Sequence of Events
-- =============================================================================
CREATE TABLE REF_HARMFUL_EVENT_TBL (
    RHE_ID                          TINYINT UNSIGNED    NOT NULL    AUTO_INCREMENT,
    RHE_CODE                        TINYINT UNSIGNED    NOT NULL    COMMENT 'MMUCC coded value for harmful/sequence event',
    RHE_DESCRIPTION                 VARCHAR(120)        NOT NULL    COMMENT 'Human-readable description of the event',
    RHE_CATEGORY                    VARCHAR(50)         NOT NULL    COMMENT 'Category: NON_HARMFUL, NON_COLLISION_HARMFUL, COLLISION_PERSON_MV, COLLISION_FIXED',

    -- Audit Columns
    RHE_CREATED_BY                  VARCHAR(100)        NOT NULL    COMMENT 'User ID or system name that created this record',
    RHE_CREATED_DT                  DATETIME            NOT NULL    DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when record was created',
    RHE_MODIFIED_BY                 VARCHAR(100)        NULL        COMMENT 'User ID or system name that last modified this record',
    RHE_MODIFIED_DT                 DATETIME            NULL        COMMENT 'Timestamp when record was last modified',
    RHE_LAST_UPDATED_ACTIVITY_CODE  VARCHAR(20)         NOT NULL    COMMENT 'Values: CREATE=Initial creation, UPDATE=Manual update, IMPORT=Bulk import, CORRECT=Data correction, REVIEW=Reviewed and approved',

    PRIMARY KEY (RHE_ID),
    UNIQUE KEY UQ_RHE_CODE (RHE_CODE),
    INDEX IDX_RHE_CATEGORY (RHE_CATEGORY)
) ENGINE=InnoDB COMMENT='Reference: MMUCC C7/V20/V21 Harmful Event and Sequence of Events lookup values';

INSERT INTO REF_HARMFUL_EVENT_TBL (RHE_CODE, RHE_DESCRIPTION, RHE_CATEGORY, RHE_CREATED_BY, RHE_LAST_UPDATED_ACTIVITY_CODE) VALUES
-- Non-Harmful Events (V20 codes 01-10)
(1,  'Cross Centerline',                            'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(2,  'Cross Median',                                'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(3,  'End Departure',                               'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(4,  'Downhill Runaway',                            'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(5,  'Equipment Failure',                           'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(6,  'Ran Off Roadway Left',                        'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(7,  'Ran Off Roadway Right',                       'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(8,  'Reentering Roadway',                          'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(9,  'Separation of Units',                         'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
(10, 'Other Non-Harmful Event',                     'NON_HARMFUL', 'SYSTEM', 'IMPORT'),
-- Non-Collision Harmful Events (V20 codes 11-18)
(11, 'Cargo/Equipment Loss or Shift',               'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(12, 'Fell/Jumped From Motor Vehicle',              'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(13, 'Fire/Explosion',                              'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(14, 'Immersion, Full or Partial',                  'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(15, 'Jackknife',                                   'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(16, 'Other Non-Collision Harmful Event',           'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(17, 'Overturn/Rollover',                           'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
(18, 'Thrown or Falling Object',                    'NON_COLLISION_HARMFUL', 'SYSTEM', 'IMPORT'),
-- Collision With Person, MV, or Non-Fixed Object (V20 codes 19-29)
(19, 'Animal (live)',                               'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(20, 'Motor Vehicle in Transport',                  'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(21, 'Other Non-Fixed Object',                      'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(22, 'Other Non-Motorist',                          'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(23, 'Parked Motor Vehicle',                        'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(24, 'Pedalcycle',                                  'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(25, 'Pedestrian',                                  'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(26, 'Railway Vehicle (train, engine)',             'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(27, 'Strikes Object at Rest from MV in Transport', 'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(28, 'Struck by Falling/Shifting Cargo from MV',   'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
(29, 'Work Zone/Maintenance Equipment',             'COLLISION_PERSON_MV', 'SYSTEM', 'IMPORT'),
-- Collision With Fixed Object (V20 codes 30-51)
(30, 'Bridge Overhead Structure',                   'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(31, 'Bridge Pier or Support',                      'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(32, 'Bridge Rail',                                 'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(33, 'Cable Barrier',                               'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(34, 'Concrete Traffic Barrier',                    'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(35, 'Culvert',                                     'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(36, 'Curb',                                        'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(37, 'Ditch',                                       'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(38, 'Embankment',                                  'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(39, 'Fence',                                       'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(40, 'Guardrail End Terminal',                      'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(41, 'Guardrail Face',                              'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(42, 'Impact Attenuator/Crash Cushion',             'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(43, 'Mailbox',                                     'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(44, 'Other Fixed Object (wall, building, tunnel)', 'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(45, 'Other Post, Pole, or Support',                'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(46, 'Other Traffic Barrier',                       'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(47, 'Traffic Sign Support',                        'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(48, 'Traffic Signal Support',                      'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(49, 'Tree (standing)',                             'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(50, 'Utility Pole/Light Support',                  'COLLISION_FIXED', 'SYSTEM', 'IMPORT'),
(51, 'Unknown Fixed Object',                        'COLLISION_FIXED', 'SYSTEM', 'IMPORT');
