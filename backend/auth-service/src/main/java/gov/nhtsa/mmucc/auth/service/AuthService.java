package gov.nhtsa.mmucc.auth.service;

import gov.nhtsa.mmucc.auth.config.JwtProperties;
import gov.nhtsa.mmucc.auth.dto.TokenResponse;
import gov.nhtsa.mmucc.auth.dto.UserSummaryResponse;
import gov.nhtsa.mmucc.auth.entity.AppUser;
import gov.nhtsa.mmucc.auth.firebase.FirebaseAuthGateway;
import gov.nhtsa.mmucc.auth.firebase.FirebaseTokenClaims;
import gov.nhtsa.mmucc.auth.mapper.UserMapper;
import gov.nhtsa.mmucc.auth.repository.AppUserRepository;
import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.JwtUtils;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.HexFormat;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

    private final FirebaseAuthGateway firebaseAuthGateway;
    private final AppUserRepository userRepository;
    private final JwtUtils jwtUtils;
    private final JwtProperties jwtProperties;
    private final AuditLogService auditLogService;
    private final UserMapper userMapper;

    public AuthService(FirebaseAuthGateway firebaseAuthGateway,
                       AppUserRepository userRepository,
                       JwtUtils jwtUtils,
                       JwtProperties jwtProperties,
                       AuditLogService auditLogService,
                       UserMapper userMapper) {
        this.firebaseAuthGateway = firebaseAuthGateway;
        this.userRepository = userRepository;
        this.jwtUtils = jwtUtils;
        this.jwtProperties = jwtProperties;
        this.auditLogService = auditLogService;
        this.userMapper = userMapper;
    }

    /**
     * Login flow:
     * 1. Verify Firebase ID token
     * 2. Look up user by Firebase UID; auto-provision as VIEWER on first login
     * 3. Check account status
     * 4. Generate tokens, store refresh token hash, write audit log
     *
     * @return [accessToken, rawRefreshToken] — caller sets the refresh token as HttpOnly cookie
     */
    @Transactional
    public LoginResult login(String firebaseIdToken, String ipAddress, String sessionId) {
        FirebaseTokenClaims claims = firebaseAuthGateway.verifyIdToken(firebaseIdToken);

        AppUser user = userRepository.findByFirebaseUid(claims.uid())
                .orElseGet(() -> autoProvision(claims));

        if (!user.isActive()) {
            throw new MmuccException.AccountDisabledException();
        }
        if (user.isAccountLocked()) {
            throw new MmuccException.AccountLockedException();
        }

        String rawRefreshToken = generateRawRefreshToken();
        String refreshTokenHash = hashToken(rawRefreshToken);
        LocalDateTime refreshExpiry = LocalDateTime.now()
                .plusDays(jwtProperties.getRefreshTokenExpirationDays());

        user.setLastLoginDt(LocalDateTime.now());
        user.setFailedLoginCount(0);
        user.setRefreshTokenHash(refreshTokenHash);
        user.setRefreshTokenExpiry(refreshExpiry);
        user.getAudit().setModifiedBy(claims.uid());
        user.getAudit().setModifiedDt(LocalDateTime.now());
        user.getAudit().setLastUpdatedActivityCode("UPDATE");
        userRepository.save(user);

        String accessToken = jwtUtils.generateAccessToken(
                user.getUserId(), user.getFirebaseUid(), user.getUsername(),
                user.getEmail(), user.getRoleCode(), user.getAgencyCode());

        auditLogService.recordLogin(user, ipAddress, sessionId);

        log.info("Login success: userId={} role={}", user.getUserId(), user.getRoleCode());

        TokenResponse tokenResponse = new TokenResponse(
                accessToken,
                jwtProperties.getAccessTokenExpirationMs() / 1000,
                "Bearer",
                userMapper.toSummaryResponse(user)
        );
        return new LoginResult(tokenResponse, rawRefreshToken);
    }

    /**
     * Refresh flow: validate the refresh token, rotate it, issue a new access token.
     *
     * @return [newAccessToken, newRawRefreshToken]
     */
    @Transactional
    public LoginResult refresh(String rawRefreshToken) {
        String tokenHash = hashToken(rawRefreshToken);

        AppUser user = userRepository.findAll().stream()
                .filter(u -> tokenHash.equals(u.getRefreshTokenHash()))
                .findFirst()
                .orElseThrow(MmuccException.RefreshTokenExpiredException::new);

        if (user.getRefreshTokenExpiry() == null ||
                user.getRefreshTokenExpiry().isBefore(LocalDateTime.now())) {
            // Expired — clear the hash to invalidate and force re-login
            user.setRefreshTokenHash(null);
            user.setRefreshTokenExpiry(null);
            userRepository.save(user);
            throw new MmuccException.RefreshTokenExpiredException();
        }

        if (!user.isActive() || user.isAccountLocked()) {
            throw new MmuccException.AccountDisabledException();
        }

        // Rotate the refresh token
        String newRawToken = generateRawRefreshToken();
        user.setRefreshTokenHash(hashToken(newRawToken));
        user.setRefreshTokenExpiry(LocalDateTime.now()
                .plusDays(jwtProperties.getRefreshTokenExpirationDays()));
        user.getAudit().setModifiedBy(user.getFirebaseUid());
        user.getAudit().setModifiedDt(LocalDateTime.now());
        user.getAudit().setLastUpdatedActivityCode("UPDATE");
        userRepository.save(user);

        String accessToken = jwtUtils.generateAccessToken(
                user.getUserId(), user.getFirebaseUid(), user.getUsername(),
                user.getEmail(), user.getRoleCode(), user.getAgencyCode());

        TokenResponse tokenResponse = new TokenResponse(
                accessToken,
                jwtProperties.getAccessTokenExpirationMs() / 1000,
                "Bearer",
                userMapper.toSummaryResponse(user)
        );
        return new LoginResult(tokenResponse, newRawToken);
    }

    /**
     * Logout: clear the refresh token hash so it cannot be reused.
     */
    @Transactional
    public void logout(UserPrincipal principal, String ipAddress, String sessionId) {
        userRepository.findById(principal.getUserId()).ifPresent(user -> {
            user.setRefreshTokenHash(null);
            user.setRefreshTokenExpiry(null);
            user.getAudit().setModifiedBy(principal.getUsername());
            user.getAudit().setModifiedDt(LocalDateTime.now());
            user.getAudit().setLastUpdatedActivityCode("UPDATE");
            userRepository.save(user);
            auditLogService.recordLogout(user, ipAddress, sessionId);
            log.info("Logout: userId={}", principal.getUserId());
        });
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private AppUser autoProvision(FirebaseTokenClaims claims) {
        log.info("Auto-provisioning new user for Firebase UID: {}", claims.uid());

        AppUser user = new AppUser();
        user.setFirebaseUid(claims.uid());
        user.setEmail(claims.email() != null ? claims.email() : claims.uid() + "@firebase");
        user.setUsername(deriveUsername(claims));
        user.setRoleCode(RoleCode.VIEWER.name());
        user.setActive(true);
        user.setAccountLocked(false);
        user.setFailedLoginCount(0);

        if (claims.name() != null) {
            String[] parts = claims.name().split(" ", 2);
            user.setFirstName(parts[0]);
            if (parts.length > 1) user.setLastName(parts[1]);
        }

        AuditFields audit = new AuditFields();
        audit.setCreatedBy(claims.uid());
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
        user.setAudit(audit);

        return userRepository.save(user);
    }

    private String deriveUsername(FirebaseTokenClaims claims) {
        if (claims.email() != null) {
            String base = claims.email().split("@")[0].replaceAll("[^a-zA-Z0-9._-]", "");
            return base.length() > 50 ? base.substring(0, 50) : base;
        }
        return claims.uid().length() > 50 ? claims.uid().substring(0, 50) : claims.uid();
    }

    private String generateRawRefreshToken() {
        byte[] bytes = new byte[64];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hashBytes);
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 not available", e);
        }
    }

    /** Simple holder to return both the response body and the raw refresh token together. */
    public record LoginResult(TokenResponse tokenResponse, String rawRefreshToken) {}
}
