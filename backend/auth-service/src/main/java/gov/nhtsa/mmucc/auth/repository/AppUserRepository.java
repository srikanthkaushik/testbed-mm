package gov.nhtsa.mmucc.auth.repository;

import gov.nhtsa.mmucc.auth.entity.AppUser;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.Optional;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {

    Optional<AppUser> findByFirebaseUid(String firebaseUid);

    Optional<AppUser> findByEmail(String email);

    Optional<AppUser> findByUsername(String username);

    boolean existsByEmail(String email);

    boolean existsByUsername(String username);

    boolean existsByFirebaseUid(String firebaseUid);

    Page<AppUser> findByRoleCode(String roleCode, Pageable pageable);

    /** Updates login metadata without fetching the full entity. */
    @Modifying
    @Query("""
            UPDATE AppUser u SET
                u.lastLoginDt = :now,
                u.failedLoginCount = 0,
                u.refreshTokenHash = :tokenHash,
                u.refreshTokenExpiry = :tokenExpiry,
                u.audit.modifiedBy = :actor,
                u.audit.modifiedDt = :now,
                u.audit.lastUpdatedActivityCode = 'UPDATE'
            WHERE u.userId = :id
            """)
    void updateLoginMetadata(@Param("id") Long id,
                             @Param("now") LocalDateTime now,
                             @Param("tokenHash") String tokenHash,
                             @Param("tokenExpiry") LocalDateTime tokenExpiry,
                             @Param("actor") String actor);
}
