package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleTrafficControl;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleTrafficControlRepository extends JpaRepository<VehicleTrafficControl, Long> {
    List<VehicleTrafficControl> findByVehicleIdOrderBySequenceNum(Long vehicleId);
    void deleteAllByVehicleId(Long vehicleId);
}
