package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_SEQUENCE_EVENT_TBL")
@Getter
@Setter
public class VehicleSequenceEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VSE_ID")
    private Long id;

    @Column(name = "VSE_VEHICLE_ID", nullable = false)
    private Long vehicleId;

    @Column(name = "VSE_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VSE_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "VSE_EVENT_CODE", nullable = false)
    private Integer eventCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VSE_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VSE_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VSE_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VSE_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VSE_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
