package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.FatalSection;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface FatalSectionRepository extends JpaRepository<FatalSection, Long> {
    Optional<FatalSection> findByPersonId(Long personId);
    void deleteByPersonId(Long personId);
}
