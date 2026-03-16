package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "NON_MOTORIST_SAFETY_EQUIPMENT_TBL")
@Getter
@Setter
public class NonMotoristSafetyEquipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "NMS_ID")
    private Long id;

    @Column(name = "NMS_NMT_ID", nullable = false)
    private Long nmtId;

    @Column(name = "NMS_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "NMS_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "NMS_EQUIPMENT_CODE", nullable = false)
    private Integer equipmentCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "NMS_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "NMS_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "NMS_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "NMS_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "NMS_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
