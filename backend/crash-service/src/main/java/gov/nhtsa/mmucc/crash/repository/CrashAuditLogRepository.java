package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.CrashAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CrashAuditLogRepository extends JpaRepository<CrashAuditLog, Long> {
}
