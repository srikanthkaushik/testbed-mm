package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleAutomation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface VehicleAutomationRepository extends JpaRepository<VehicleAutomation, Long> {
    Optional<VehicleAutomation> findByVehicleId(Long vehicleId);
    void deleteByVehicleId(Long vehicleId);
}
