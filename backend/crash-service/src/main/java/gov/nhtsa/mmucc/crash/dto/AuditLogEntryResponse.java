package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDateTime;

/** Read-only projection of one CRASH_AUDIT_LOG_TBL row returned by GET /crashes/{id}/audit. */
public record AuditLogEntryResponse(
        Long    auditId,
        String  actionCode,
        String  tableName,
        Long    recordId,
        String  username,
        LocalDateTime timestamp,
        String  oldValue,
        String  newValue
) {}
