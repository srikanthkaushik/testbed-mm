package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "PERSON_DRIVER_ACTION_TBL")
@Getter
@Setter
public class PersonDriverAction {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PDA_ID")
    private Long id;

    @Column(name = "PDA_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "PDA_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "PDA_SEQUENCE_NUM", nullable = false)
    private Integer sequenceNum;

    @Column(name = "PDA_ACTION_CODE", nullable = false)
    private Integer actionCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "PDA_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "PDA_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "PDA_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "PDA_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "PDA_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
