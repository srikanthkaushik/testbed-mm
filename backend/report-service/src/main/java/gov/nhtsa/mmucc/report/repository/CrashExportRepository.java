package gov.nhtsa.mmucc.report.repository;

import gov.nhtsa.mmucc.report.entity.CrashExport;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface CrashExportRepository extends JpaRepository<CrashExport, Long> {

    @Query("""
            SELECT c FROM CrashExport c WHERE
            (:dateFrom   IS NULL OR c.crashDate        >= :dateFrom)   AND
            (:dateTo     IS NULL OR c.crashDate        <= :dateTo)     AND
            (:severity   IS NULL OR c.crashSeverityCode = :severity)   AND
            (:countyCode IS NULL OR c.countyFipsCode    = :countyCode)
            ORDER BY c.crashDate DESC, c.crashId DESC
            """)
    List<CrashExport> findForExport(
            @Param("dateFrom")   LocalDate dateFrom,
            @Param("dateTo")     LocalDate dateTo,
            @Param("severity")   Integer   severity,
            @Param("countyCode") String    countyCode);
}
