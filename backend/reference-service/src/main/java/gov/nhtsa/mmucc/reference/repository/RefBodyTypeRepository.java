package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefBodyType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefBodyTypeRepository extends JpaRepository<RefBodyType, Integer> {
    List<RefBodyType> findAllByOrderByCodeAsc();
}
