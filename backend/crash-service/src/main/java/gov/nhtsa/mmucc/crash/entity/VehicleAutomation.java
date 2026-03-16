package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_AUTOMATION_TBL")
@Getter
@Setter
public class VehicleAutomation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VAT_ID")
    private Long id;

    @Column(name = "VAT_VEHICLE_ID", nullable = false)
    private Long vehicleId;

    @Column(name = "VAT_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VAT_AUTOMATION_PRESENT_CODE")
    private Integer automationPresentCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VAT_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VAT_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VAT_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VAT_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VAT_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
