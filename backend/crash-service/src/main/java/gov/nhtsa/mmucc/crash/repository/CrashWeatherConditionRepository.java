package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.CrashWeatherCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CrashWeatherConditionRepository extends JpaRepository<CrashWeatherCondition, Long> {
    List<CrashWeatherCondition> findByCrashIdOrderBySequenceNum(Long crashId);
    void deleteAllByCrashId(Long crashId);
}
