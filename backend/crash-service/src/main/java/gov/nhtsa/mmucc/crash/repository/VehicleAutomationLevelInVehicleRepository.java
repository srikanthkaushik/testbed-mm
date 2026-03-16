package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleAutomationLevelInVehicle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleAutomationLevelInVehicleRepository extends JpaRepository<VehicleAutomationLevelInVehicle, Long> {
    List<VehicleAutomationLevelInVehicle> findByVatIdOrderBySequenceNum(Long vatId);
    void deleteAllByVatId(Long vatId);
}
