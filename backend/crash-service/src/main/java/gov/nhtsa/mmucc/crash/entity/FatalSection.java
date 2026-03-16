package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "FATAL_SECTION_TBL")
@Getter
@Setter
public class FatalSection {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "FSC_ID")
    private Long id;

    @Column(name = "FSC_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "FSC_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "FSC_AVOIDANCE_MANEUVER_CODE")
    private Integer avoidanceManeuverCode;

    @Column(name = "FSC_ALCOHOL_TEST_TYPE_CODE")
    private Integer alcoholTestTypeCode;

    @Column(name = "FSC_ALCOHOL_TEST_RESULT", length = 10)
    private String alcoholTestResult;

    @Column(name = "FSC_DRUG_TEST_TYPE_CODE")
    private Integer drugTestTypeCode;

    @Column(name = "FSC_DRUG_TEST_RESULT")
    private Integer drugTestResult;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "FSC_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "FSC_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "FSC_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "FSC_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "FSC_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
