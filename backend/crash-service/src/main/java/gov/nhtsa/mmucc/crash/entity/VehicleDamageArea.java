package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_DAMAGE_AREA_TBL")
@Getter
@Setter
public class VehicleDamageArea {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VDA_ID")
    private Long id;

    @Column(name = "VDA_VEHICLE_ID", nullable = false)
    private Long vehicleId;

    @Column(name = "VDA_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VDA_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "VDA_AREA_CODE", nullable = false)
    private Integer areaCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "VDA_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "VDA_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "VDA_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "VDA_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "VDA_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
