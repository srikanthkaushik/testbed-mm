package gov.nhtsa.mmucc.auth.repository;

import gov.nhtsa.mmucc.auth.entity.CrashAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CrashAuditLogRepository extends JpaRepository<CrashAuditLog, Long> {
    // Auth-service only ever calls save() on this repository.
}
