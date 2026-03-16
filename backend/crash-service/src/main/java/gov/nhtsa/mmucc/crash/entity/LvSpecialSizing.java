package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "LV_SPECIAL_SIZING_TBL")
@Getter
@Setter
public class LvSpecialSizing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LVS_ID")
    private Long id;

    @Column(name = "LVS_LVH_ID", nullable = false)
    private Long lvhId;

    @Column(name = "LVS_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "LVS_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "LVS_SIZING_CODE", nullable = false)
    private Integer sizingCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "LVS_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "LVS_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "LVS_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "LVS_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "LVS_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
