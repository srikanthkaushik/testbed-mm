package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.Crash;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;

public interface CrashRepository extends JpaRepository<Crash, Long> {

    @Query("""
            SELECT c FROM Crash c WHERE
            (:dateFrom  IS NULL OR c.crashDate        >= :dateFrom)  AND
            (:dateTo    IS NULL OR c.crashDate        <= :dateTo)    AND
            (:severity  IS NULL OR c.crashSeverityCode = :severity)  AND
            (:county    IS NULL OR c.countyFipsCode    = :county)
            """)
    Page<Crash> findByFilters(
            @Param("dateFrom")  LocalDate dateFrom,
            @Param("dateTo")    LocalDate dateTo,
            @Param("severity")  Integer   severity,
            @Param("county")    String    county,
            Pageable pageable);
}
