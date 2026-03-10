package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_TRAFFIC_CONTROL_TBL")
@Getter
@Setter
public class VehicleTrafficControl {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VTC_ID")
    private Long id;

    @Column(name = "VTC_VEHICLE_ID", nullable = false)
    private Long vehicleId;

    @Column(name = "VTC_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VTC_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "VTC_TCD_TYPE_CODE", nullable = false)
    private Integer tcdTypeCode;

    @Column(name = "VTC_TCD_INOPERATIVE_CODE")
    private Integer tcdInoperativeCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VTC_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VTC_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VTC_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VTC_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VTC_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
