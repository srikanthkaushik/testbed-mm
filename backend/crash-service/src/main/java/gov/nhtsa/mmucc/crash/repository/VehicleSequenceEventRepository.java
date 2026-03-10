package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleSequenceEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleSequenceEventRepository extends JpaRepository<VehicleSequenceEvent, Long> {
    List<VehicleSequenceEvent> findByVehicleIdOrderBySequenceNum(Long vehicleId);
    void deleteAllByVehicleId(Long vehicleId);
}
