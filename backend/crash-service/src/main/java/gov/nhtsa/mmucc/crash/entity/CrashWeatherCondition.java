package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "CRASH_WEATHER_CONDITION_TBL")
@Getter
@Setter
public class CrashWeatherCondition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CWC_ID")
    private Long id;

    @Column(name = "CWC_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "CWC_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "CWC_WEATHER_CODE", nullable = false)
    private Integer weatherCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "CWC_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "CWC_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "CWC_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "CWC_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "CWC_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
