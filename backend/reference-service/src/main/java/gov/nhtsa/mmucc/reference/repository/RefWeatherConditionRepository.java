package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefWeatherCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefWeatherConditionRepository extends JpaRepository<RefWeatherCondition, Integer> {
    List<RefWeatherCondition> findAllByOrderByCodeAsc();
}
