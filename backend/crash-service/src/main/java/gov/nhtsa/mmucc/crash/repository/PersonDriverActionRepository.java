package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.PersonDriverAction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PersonDriverActionRepository extends JpaRepository<PersonDriverAction, Long> {
    List<PersonDriverAction> findByPersonIdOrderBySequenceNum(Long personId);
    void deleteAllByPersonId(Long personId);
}
