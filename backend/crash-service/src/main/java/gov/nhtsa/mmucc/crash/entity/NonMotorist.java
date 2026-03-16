package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "NON_MOTORIST_TBL")
@Getter
@Setter
public class NonMotorist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "NMT_ID")
    private Long id;

    @Column(name = "NMT_PERSON_ID", nullable = false)
    private Long personId;

    @Column(name = "NMT_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "NMT_STRIKING_VEHICLE_UNIT")
    private Integer strikingVehicleUnit;

    @Column(name = "NMT_ACTION_CIRC_CODE")
    private Integer actionCircCode;

    @Column(name = "NMT_ORIGIN_DESTINATION_CODE")
    private Integer originDestinationCode;

    @Column(name = "NMT_CONTRIBUTING_ACTION_1")
    private Integer contributingAction1;

    @Column(name = "NMT_CONTRIBUTING_ACTION_2")
    private Integer contributingAction2;

    @Column(name = "NMT_LOCATION_AT_CRASH_CODE")
    private Integer locationAtCrashCode;

    @Column(name = "NMT_INITIAL_CONTACT_POINT")
    private Integer initialContactPoint;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "NMT_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "NMT_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "NMT_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "NMT_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "NMT_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
