package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefSurfaceCondition;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefSurfaceConditionRepository extends JpaRepository<RefSurfaceCondition, Integer> {
    List<RefSurfaceCondition> findAllByOrderByCodeAsc();
}
