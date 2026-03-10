package gov.nhtsa.mmucc.common.audit;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

/**
 * Reusable embeddable for the five audit columns present on every MMUCC table.
 * <p>
 * Column names are NOT declared here — each embedding entity must supply
 * {@code @AttributeOverrides} using the table-specific 3-letter prefix
 * (e.g., {@code AUS_CREATED_BY} for APP_USER_TBL, {@code CRS_CREATED_BY}
 * for CRASH_TBL, etc.).
 * <p>
 * The service layer is responsible for populating these fields before every
 * save operation. This keeps audit author identity explicit and prevents
 * JPA lifecycle hooks from accidentally capturing the wrong principal.
 */
@Embeddable
@Getter
@Setter
public class AuditFields {

    private String createdBy;

    private LocalDateTime createdDt;

    private String modifiedBy;

    private LocalDateTime modifiedDt;

    private String lastUpdatedActivityCode;
}
