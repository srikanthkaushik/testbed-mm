package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL")
@Getter
@Setter
public class VehicleAutomationLevelEngaged {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VAE_ID")
    private Long id;

    @Column(name = "VAE_VAT_ID", nullable = false)
    private Long vatId;

    @Column(name = "VAE_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VAE_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "VAE_AUTOMATION_LEVEL_CODE", nullable = false)
    private Integer automationLevelCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VAE_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VAE_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VAE_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VAE_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VAE_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
