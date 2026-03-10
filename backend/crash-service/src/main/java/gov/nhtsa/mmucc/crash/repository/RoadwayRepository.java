package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.Roadway;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoadwayRepository extends JpaRepository<Roadway, Long> {

    Optional<Roadway> findByCrashId(Long crashId);

    void deleteByCrashId(Long crashId);
}
