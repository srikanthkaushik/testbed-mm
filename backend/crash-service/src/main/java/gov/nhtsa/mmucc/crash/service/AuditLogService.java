package gov.nhtsa.mmucc.crash.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import gov.nhtsa.mmucc.crash.dto.AuditLogEntryResponse;
import gov.nhtsa.mmucc.crash.entity.CrashAuditLog;
import gov.nhtsa.mmucc.crash.repository.CrashAuditLogRepository;
import gov.nhtsa.mmucc.common.audit.AuditFields;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AuditLogService {

    private static final Logger log = LoggerFactory.getLogger(AuditLogService.class);

    private final CrashAuditLogRepository repository;
    private final ObjectMapper objectMapper;

    public AuditLogService(CrashAuditLogRepository repository, ObjectMapper objectMapper) {
        this.repository = repository;
        this.objectMapper = objectMapper;
    }

    /**
     * Records a data-change event. Runs in REQUIRES_NEW so the audit entry is
     * committed even if the caller's transaction rolls back.
     *
     * @param action    CREATE, UPDATE, DELETE
     * @param tableName e.g. CRASH_TBL
     * @param recordId  PK of the affected row
     * @param username  actor username
     * @param crashId   crash PK for context (may be null for non-crash operations)
     * @param before    serialized JSON of the row before the change (null for CREATE)
     * @param after     serialized JSON of the row after the change (null for DELETE)
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(String action, String tableName, Long recordId,
                       String username, Long crashId,
                       Object before, Object after) {
        CrashAuditLog entry = new CrashAuditLog();
        entry.setActionCode(action);
        entry.setTableName(tableName);
        entry.setRecordId(recordId != null ? recordId.intValue() : null);
        entry.setUsername(username);
        entry.setCrashId(crashId != null ? crashId.intValue() : null);
        entry.setOldValue(toJson(before));
        entry.setNewValue(toJson(after));

        AuditFields audit = new AuditFields();
        audit.setCreatedBy(username);
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
        entry.setAudit(audit);

        repository.save(entry);
    }

    /** Returns all audit entries for a crash in chronological order. */
    @Transactional(readOnly = true)
    public List<AuditLogEntryResponse> getAuditLog(Long crashId) {
        return repository.findByCrashIdOrdered(crashId.intValue()).stream()
                .map(e -> new AuditLogEntryResponse(
                        e.getAuditId(),
                        e.getActionCode(),
                        e.getTableName(),
                        e.getRecordId() != null ? e.getRecordId().longValue() : null,
                        e.getUsername(),
                        e.getAudit().getCreatedDt(),
                        e.getOldValue(),
                        e.getNewValue()))
                .toList();
    }

    private String toJson(Object obj) {
        if (obj == null) return null;
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (JsonProcessingException e) {
            log.warn("Failed to serialize audit snapshot: {}", e.getMessage());
            return null;
        }
    }
}
