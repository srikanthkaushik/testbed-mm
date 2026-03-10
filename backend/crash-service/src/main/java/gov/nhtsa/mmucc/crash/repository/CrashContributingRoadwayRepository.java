package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.CrashContributingRoadway;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CrashContributingRoadwayRepository extends JpaRepository<CrashContributingRoadway, Long> {
    List<CrashContributingRoadway> findByCrashIdOrderBySequenceNum(Long crashId);
    void deleteAllByCrashId(Long crashId);
}
