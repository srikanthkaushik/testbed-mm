package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "PERSON_DRUG_TEST_RESULT_TBL")
@Getter
@Setter
public class PersonDrugTestResult {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "DTR_ID")
    private Long id;

    @Column(name = "DTR_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "DTR_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "DTR_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "DTR_RESULT_CODE", nullable = false)
    private Integer resultCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "DTR_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "DTR_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "DTR_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "DTR_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "DTR_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
