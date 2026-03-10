package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleDamageArea;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleDamageAreaRepository extends JpaRepository<VehicleDamageArea, Long> {
    List<VehicleDamageArea> findByVehicleIdOrderBySequenceNum(Long vehicleId);
    void deleteAllByVehicleId(Long vehicleId);
}
