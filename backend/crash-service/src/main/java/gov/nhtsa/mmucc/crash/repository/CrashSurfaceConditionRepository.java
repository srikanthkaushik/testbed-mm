package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.CrashSurfaceCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CrashSurfaceConditionRepository extends JpaRepository<CrashSurfaceCondition, Long> {
    List<CrashSurfaceCondition> findByCrashIdOrderBySequenceNum(Long crashId);
    void deleteAllByCrashId(Long crashId);
}
