package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

/** Append-only audit log. crash-service writes CREATE/UPDATE/DELETE events here. */
@Entity
@Table(name = "CRASH_AUDIT_LOG_TBL")
@Getter
@Setter
public class CrashAuditLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CAL_AUDIT_ID")
    private Long auditId;

    @Column(name = "CAL_CRASH_ID")
    private Integer crashId;

    @Column(name = "CAL_USER_ID")
    private Integer userId;

    @Column(name = "CAL_USERNAME", nullable = false, length = 50)
    private String username;

    @Column(name = "CAL_ACTION_CODE", nullable = false, length = 20)
    private String actionCode;

    @Column(name = "CAL_TABLE_NAME", nullable = false, length = 60)
    private String tableName;

    @Column(name = "CAL_RECORD_ID")
    private Integer recordId;

    @Column(name = "CAL_OLD_VALUE", columnDefinition = "JSON")
    private String oldValue;

    @Column(name = "CAL_NEW_VALUE", columnDefinition = "JSON")
    private String newValue;

    @Column(name = "CAL_IP_ADDRESS", length = 45)
    private String ipAddress;

    @Column(name = "CAL_SESSION_ID", length = 100)
    private String sessionId;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "CAL_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "CAL_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "CAL_MODIFIED_BY",                  length = 100, insertable = false, updatable = false)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "CAL_MODIFIED_DT",                  insertable = false, updatable = false)),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "CAL_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
