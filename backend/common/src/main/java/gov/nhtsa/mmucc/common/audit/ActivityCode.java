package gov.nhtsa.mmucc.common.audit;

/**
 * Valid values for the LAST_UPDATED_ACTIVITY_CODE audit column on every table.
 */
public enum ActivityCode {
    CREATE,
    UPDATE,
    IMPORT,
    CORRECT,
    REVIEW
}
