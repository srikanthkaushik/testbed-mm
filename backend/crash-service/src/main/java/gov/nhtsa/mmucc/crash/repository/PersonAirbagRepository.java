package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.PersonAirbag;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PersonAirbagRepository extends JpaRepository<PersonAirbag, Long> {
    List<PersonAirbag> findByPersonIdOrderBySequenceNum(Long personId);
    void deleteAllByPersonId(Long personId);
}
