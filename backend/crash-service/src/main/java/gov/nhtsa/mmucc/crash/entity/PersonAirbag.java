package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "PERSON_AIRBAG_TBL")
@Getter
@Setter
public class PersonAirbag {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PAB_ID")
    private Long id;

    @Column(name = "PAB_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "PAB_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "PAB_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "PAB_AIRBAG_CODE", nullable = false)
    private Integer airbagCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "PAB_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "PAB_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "PAB_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "PAB_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "PAB_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
