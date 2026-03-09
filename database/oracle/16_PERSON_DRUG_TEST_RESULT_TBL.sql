-- =============================================================================
-- FILE:    16_PERSON_DRUG_TEST_RESULT_TBL.sql
-- SCHEMA:  MMUCC v5
-- TABLE:   PERSON_DRUG_TEST_RESULT_TBL (DTR)
-- PURPOSE: MMUCC P23 SF3 - Drug Test Results. Up to 4 drug test result
--          records per person.
-- DBMS:    Oracle 19c
-- =============================================================================

CREATE TABLE PERSON_DRUG_TEST_RESULT_TBL (

    DTR_ID                          NUMBER GENERATED ALWAYS AS IDENTITY
                                        CONSTRAINT PK_DTR PRIMARY KEY,

    DTR_PERSON_ID                   NUMBER(10)      NOT NULL,
    DTR_CRASH_ID                    NUMBER(10)      NOT NULL,
    DTR_SEQUENCE_NUM                NUMBER(3)       NOT NULL,

    -- P23 SF3 Drug Category code (FARS-aligned):
    --   1  = Narcotics (opioids - heroin, morphine, oxycodone, etc.)
    --   2  = Depressants (CNS - barbiturates, benzodiazepines, GHB, etc.)
    --   3  = Stimulants (amphetamines, methamphetamine, cocaine, etc.)
    --   4  = Hallucinogens (cannabis/marijuana, LSD, psilocybin, MDMA, etc.)
    --   5  = PCP (phencyclidine)
    --   6  = Inhalants
    --   7  = Over-the-Counter Drugs (antihistamines, cold medicine, etc.)
    --   8  = Other Drugs
    --  95  = Tested - No Drugs Found
    --  96  = Tested - Results Unavailable
    --  97  = Not Applicable (no test administered)
    --  98  = Refused (test refused)
    --  99  = Unknown
    DTR_DRUG_CATEGORY_CODE          NUMBER(3)       NOT NULL,

    -- Specific numeric result code for this individual drug test,
    -- if the jurisdiction captures sub-category detail.
    -- NULL if only the category-level code is recorded.
    DTR_DRUG_TEST_RESULT_CODE       NUMBER(3),

    -- Audit columns
    DTR_CREATED_BY                  VARCHAR2(100)   NOT NULL,
    DTR_CREATED_DT                  DATE            DEFAULT SYSDATE NOT NULL,
    DTR_MODIFIED_BY                 VARCHAR2(100),
    DTR_MODIFIED_DT                 DATE,
    DTR_LAST_UPDATED_ACTIVITY_CODE  VARCHAR2(20)    NOT NULL,

    CONSTRAINT UQ_DTR_PRS_SEQ UNIQUE (DTR_PERSON_ID, DTR_SEQUENCE_NUM)

);

-- ---------------------------------------------------------------------------
-- Table and column comments
-- ---------------------------------------------------------------------------

COMMENT ON TABLE PERSON_DRUG_TEST_RESULT_TBL IS
    'MMUCC P23 SF3 - Drug Test Results. Stores up to 4 drug test results per person involved in a crash. Drug category codes align with FARS coding.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_ID IS
    'Surrogate primary key. System-generated identity column.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_PERSON_ID IS
    'Foreign key to PERSON_TBL. The person for whom this drug test result is recorded.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_CRASH_ID IS
    'Denormalized foreign key to CRASH_TBL. Facilitates direct crash-level queries without joining through PERSON_TBL.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_SEQUENCE_NUM IS
    'Sequence of this drug test result record for the person. Valid range: 1-4.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_DRUG_CATEGORY_CODE IS
    'MMUCC P23 SF3 Drug Category code (FARS-aligned). 1=Narcotics (opioids); 2=Depressants (CNS); 3=Stimulants (amphetamines/cocaine); 4=Hallucinogens (cannabis/LSD); 5=PCP; 6=Inhalants; 7=Over-the-Counter Drugs; 8=Other Drugs; 95=Tested-No Drugs Found; 96=Tested-Results Unavailable; 97=Not Applicable; 98=Refused; 99=Unknown.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_DRUG_TEST_RESULT_CODE IS
    'Specific numeric result code for this drug test, capturing sub-category detail where available. NULL when only the category-level code is recorded.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_CREATED_BY IS
    'User or process that created this record.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_CREATED_DT IS
    'Date and time the record was created. Defaults to SYSDATE.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_MODIFIED_BY IS
    'User or process that last modified this record.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_MODIFIED_DT IS
    'Date and time the record was last modified.';

COMMENT ON COLUMN PERSON_DRUG_TEST_RESULT_TBL.DTR_LAST_UPDATED_ACTIVITY_CODE IS
    'Activity code of the last transaction that updated this record (e.g., INSERT, UPDATE, IMPORT).';

-- ---------------------------------------------------------------------------
-- Indexes
-- ---------------------------------------------------------------------------

CREATE INDEX IDX_DTR_PERSON_ID ON PERSON_DRUG_TEST_RESULT_TBL (DTR_PERSON_ID);

CREATE INDEX IDX_DTR_CRASH_ID  ON PERSON_DRUG_TEST_RESULT_TBL (DTR_CRASH_ID);

-- ---------------------------------------------------------------------------
-- Foreign key constraints
-- ---------------------------------------------------------------------------

ALTER TABLE PERSON_DRUG_TEST_RESULT_TBL
    ADD CONSTRAINT FK_DTR_PERSON
        FOREIGN KEY (DTR_PERSON_ID)
        REFERENCES PERSON_TBL (PRS_ID)
        ON DELETE CASCADE;

ALTER TABLE PERSON_DRUG_TEST_RESULT_TBL
    ADD CONSTRAINT FK_DTR_CRASH
        FOREIGN KEY (DTR_CRASH_ID)
        REFERENCES CRASH_TBL (CRH_ID)
        ON DELETE CASCADE;
