package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL")
@Getter
@Setter
public class VehicleAutomationLevelInVehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VAI_ID")
    private Long id;

    @Column(name = "VAI_VAT_ID", nullable = false)
    private Long vatId;

    @Column(name = "VAI_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VAI_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "VAI_AUTOMATION_LEVEL_CODE", nullable = false)
    private Integer automationLevelCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VAI_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VAI_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VAI_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VAI_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VAI_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
