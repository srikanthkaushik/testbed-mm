package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.Person;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PersonRepository extends JpaRepository<Person, Long> {
    List<Person> findByVehicleIdOrderByPersonId(Long vehicleId);
    Optional<Person> findByPersonIdAndVehicleId(Long personId, Long vehicleId);
    Optional<Person> findByPersonIdAndCrashId(Long personId, Long crashId);
    void deleteAllByVehicleId(Long vehicleId);
}
