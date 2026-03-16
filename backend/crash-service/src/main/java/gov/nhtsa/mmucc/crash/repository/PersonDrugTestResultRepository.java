package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.PersonDrugTestResult;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PersonDrugTestResultRepository extends JpaRepository<PersonDrugTestResult, Long> {
    List<PersonDrugTestResult> findByPersonIdOrderBySequenceNum(Long personId);
    void deleteAllByPersonId(Long personId);
}
