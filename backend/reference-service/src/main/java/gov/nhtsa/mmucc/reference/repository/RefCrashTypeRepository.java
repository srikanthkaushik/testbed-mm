package gov.nhtsa.mmucc.reference.repository;

import gov.nhtsa.mmucc.reference.entity.RefCrashType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RefCrashTypeRepository extends JpaRepository<RefCrashType, Integer> {
    List<RefCrashType> findAllByOrderByCodeAsc();
}
