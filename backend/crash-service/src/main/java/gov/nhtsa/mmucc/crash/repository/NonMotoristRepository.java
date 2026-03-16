package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.NonMotorist;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NonMotoristRepository extends JpaRepository<NonMotorist, Long> {
    Optional<NonMotorist> findByPersonId(Long personId);
    void deleteByPersonId(Long personId);
}
