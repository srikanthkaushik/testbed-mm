package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {

    List<Vehicle> findByCrashIdOrderByUnitNumber(Long crashId);

    Optional<Vehicle> findByVehicleIdAndCrashId(Long vehicleId, Long crashId);

    void deleteAllByCrashId(Long crashId);
}
