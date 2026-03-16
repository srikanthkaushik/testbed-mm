package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.PersonDlRestriction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PersonDlRestrictionRepository extends JpaRepository<PersonDlRestriction, Long> {
    List<PersonDlRestriction> findByPersonIdOrderBySequenceNum(Long personId);
    void deleteAllByPersonId(Long personId);
}
