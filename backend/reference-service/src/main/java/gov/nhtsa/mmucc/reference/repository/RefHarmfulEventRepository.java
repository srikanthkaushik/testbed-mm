package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefHarmfulEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefHarmfulEventRepository extends JpaRepository<RefHarmfulEvent, Integer> {
    List<RefHarmfulEvent> findAllByOrderByCodeAsc();
}
