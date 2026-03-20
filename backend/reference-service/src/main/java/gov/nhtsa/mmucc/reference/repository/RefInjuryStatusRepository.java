package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefInjuryStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefInjuryStatusRepository extends JpaRepository<RefInjuryStatus, Integer> {
    List<RefInjuryStatus> findAllByOrderByCodeAsc();
}
