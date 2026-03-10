package gov.nhtsa.mmucc.auth.service;

import gov.nhtsa.mmucc.auth.dto.CreateUserRequest;
import gov.nhtsa.mmucc.auth.dto.UpdateUserRoleRequest;
import gov.nhtsa.mmucc.auth.dto.UpdateUserStatusRequest;
import gov.nhtsa.mmucc.auth.dto.UserSummaryResponse;
import gov.nhtsa.mmucc.auth.entity.AppUser;
import gov.nhtsa.mmucc.auth.mapper.UserMapper;
import gov.nhtsa.mmucc.auth.repository.AppUserRepository;
import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class UserAdminService {

    private final AppUserRepository userRepository;
    private final UserMapper userMapper;

    public UserAdminService(AppUserRepository userRepository, UserMapper userMapper) {
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @Transactional
    public UserSummaryResponse createUser(CreateUserRequest req, UserPrincipal actor) {
        if (userRepository.existsByEmail(req.email())) {
            throw new MmuccException.UserAlreadyExistsException("email", req.email());
        }
        if (userRepository.existsByUsername(req.username())) {
            throw new MmuccException.UserAlreadyExistsException("username", req.username());
        }
        if (userRepository.existsByFirebaseUid(req.firebaseUid())) {
            throw new MmuccException.UserAlreadyExistsException("firebaseUid", req.firebaseUid());
        }

        // Validate role
        RoleCode.fromString(req.roleCode());

        AppUser user = userMapper.fromCreateRequest(req);

        AuditFields audit = new AuditFields();
        audit.setCreatedBy(actor.getUsername());
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
        user.setAudit(audit);

        return userMapper.toSummaryResponse(userRepository.save(user));
    }

    public UserSummaryResponse getUserById(Long id) {
        return userMapper.toSummaryResponse(findOrThrow(id));
    }

    public Page<UserSummaryResponse> listUsers(int page, int size, String roleFilter) {
        PageRequest pageable = PageRequest.of(page, Math.min(size, 100));
        if (roleFilter != null && !roleFilter.isBlank()) {
            return userRepository.findByRoleCode(roleFilter.toUpperCase(), pageable)
                    .map(userMapper::toSummaryResponse);
        }
        return userRepository.findAll(pageable).map(userMapper::toSummaryResponse);
    }

    @Transactional
    public UserSummaryResponse updateRole(Long id, UpdateUserRoleRequest req, UserPrincipal actor) {
        RoleCode.fromString(req.roleCode()); // validate

        AppUser user = findOrThrow(id);
        user.setRoleCode(req.roleCode().toUpperCase());
        setModifiedAudit(user.getAudit(), actor.getUsername());
        return userMapper.toSummaryResponse(userRepository.save(user));
    }

    @Transactional
    public UserSummaryResponse updateStatus(Long id, UpdateUserStatusRequest req, UserPrincipal actor) {
        AppUser user = findOrThrow(id);
        user.setActive(req.active());
        if (req.active()) {
            user.setAccountLocked(false);
            user.setFailedLoginCount(0);
        }
        setModifiedAudit(user.getAudit(), actor.getUsername());
        return userMapper.toSummaryResponse(userRepository.save(user));
    }

    // -----------------------------------------------------------------------

    private AppUser findOrThrow(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(String.valueOf(id)));
    }

    private void setModifiedAudit(AuditFields audit, String actor) {
        audit.setModifiedBy(actor);
        audit.setModifiedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("UPDATE");
    }
}
