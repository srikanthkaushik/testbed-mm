package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "PERSON_DL_RESTRICTION_TBL")
@Getter
@Setter
public class PersonDlRestriction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PDR_ID")
    private Long id;

    @Column(name = "PDR_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "PDR_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "PDR_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "PDR_RESTRICTION_CODE", nullable = false)
    private Integer restrictionCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "PDR_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "PDR_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "PDR_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "PDR_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "PDR_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
