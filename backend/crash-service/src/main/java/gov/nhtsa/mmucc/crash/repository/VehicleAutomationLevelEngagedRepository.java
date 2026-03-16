package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.VehicleAutomationLevelEngaged;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VehicleAutomationLevelEngagedRepository extends JpaRepository<VehicleAutomationLevelEngaged, Long> {
    List<VehicleAutomationLevelEngaged> findByVatIdOrderBySequenceNum(Long vatId);
    void deleteAllByVatId(Long vatId);
}
