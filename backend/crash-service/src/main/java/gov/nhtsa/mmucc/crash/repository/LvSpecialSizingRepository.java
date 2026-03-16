package gov.nhtsa.mmucc.crash.repository;

import gov.nhtsa.mmucc.crash.entity.LvSpecialSizing;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface LvSpecialSizingRepository extends JpaRepository<LvSpecialSizing, Long> {
    List<LvSpecialSizing> findByLvhIdOrderBySequenceNum(Long lvhId);
    void deleteAllByLvhId(Long lvhId);
}
