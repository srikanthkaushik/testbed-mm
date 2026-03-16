package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.LargeVehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LargeVehicleRepository extends JpaRepository<LargeVehicle, Long> {
    Optional<LargeVehicle> findByVehicleId(Long vehicleId);
    void deleteByVehicleId(Long vehicleId);
}
