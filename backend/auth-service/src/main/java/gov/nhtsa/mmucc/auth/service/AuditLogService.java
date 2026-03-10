package gov.nhtsa.mmucc.auth.service;

import gov.nhtsa.mmucc.auth.entity.AppUser;
import gov.nhtsa.mmucc.auth.entity.CrashAuditLog;
import gov.nhtsa.mmucc.auth.repository.CrashAuditLogRepository;
import gov.nhtsa.mmucc.common.audit.AuditFields;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class AuditLogService {

    private final CrashAuditLogRepository repository;

    public AuditLogService(CrashAuditLogRepository repository) {
        this.repository = repository;
    }

    /**
     * Writes a LOGIN event. Uses REQUIRES_NEW so the audit log entry is committed
     * even if the outer transaction rolls back — government compliance requirement.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordLogin(AppUser user, String ipAddress, String sessionId) {
        repository.save(buildEntry(user, "LOGIN", ipAddress, sessionId));
    }

    /**
     * Writes a LOGOUT event. Same propagation contract as recordLogin.
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordLogout(AppUser user, String ipAddress, String sessionId) {
        repository.save(buildEntry(user, "LOGOUT", ipAddress, sessionId));
    }

    private CrashAuditLog buildEntry(AppUser user, String actionCode,
                                     String ipAddress, String sessionId) {
        CrashAuditLog entry = new CrashAuditLog();
        entry.setActionCode(actionCode);
        entry.setTableName("APP_USER_TBL");
        entry.setUserId(user.getUserId() != null ? user.getUserId().intValue() : null);
        entry.setUsername(user.getUsername());
        entry.setIpAddress(ipAddress);
        entry.setSessionId(sessionId);

        AuditFields audit = new AuditFields();
        audit.setCreatedBy(user.getUsername());
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
        entry.setAudit(audit);

        return entry;
    }
}
