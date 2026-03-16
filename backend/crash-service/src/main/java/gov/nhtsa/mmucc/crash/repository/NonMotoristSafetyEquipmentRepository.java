package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.NonMotoristSafetyEquipment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface NonMotoristSafetyEquipmentRepository extends JpaRepository<NonMotoristSafetyEquipment, Long> {
    List<NonMotoristSafetyEquipment> findByNmtIdOrderBySequenceNum(Long nmtId);
    void deleteAllByNmtId(Long nmtId);
}
