-- =============================================================================
-- Migration  : V5 – Convert CHAR columns to VARCHAR to match Hibernate entities
-- Service    : crash-service
-- Target DB  : mmucc5
-- Notes      : Original DDL used CHAR(1) for RWY_GRADE_DIRECTION; Hibernate
--              maps String fields to VARCHAR. Safe no-op in Testcontainers
--              where V1 already creates this column as VARCHAR(1).
-- =============================================================================

ALTER TABLE ROADWAY_TBL
    MODIFY COLUMN RWY_GRADE_DIRECTION VARCHAR(1) NULL;
