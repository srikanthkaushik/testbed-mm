package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefPersonType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefPersonTypeRepository extends JpaRepository<RefPersonType, Integer> {
    List<RefPersonType> findAllByOrderByCodeAsc();
}
