package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "CRASH_CONTRIBUTING_ROADWAY_TBL")
@Getter
@Setter
public class CrashContributingRoadway {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CCR_ID")
    private Long id;

    @Column(name = "CCR_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "CCR_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "CCR_CIRCUMSTANCE_CODE", nullable = false)
    private Integer circumstanceCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "CCR_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "CCR_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "CCR_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "CCR_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "CCR_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
