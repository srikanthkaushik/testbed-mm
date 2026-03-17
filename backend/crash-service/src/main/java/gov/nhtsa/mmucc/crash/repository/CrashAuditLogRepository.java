package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.CrashAuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CrashAuditLogRepository extends JpaRepository<CrashAuditLog, Long> {

    @org.springframework.data.jpa.repository.Query(
        "SELECT a FROM CrashAuditLog a WHERE a.crashId = :crashId ORDER BY a.audit.createdDt ASC")
    java.util.List<CrashAuditLog> findByCrashIdOrdered(@org.springframework.data.repository.query.Param("crashId") Integer crashId);
}
