package gov.nhtsa.mmucc.auth.controller;

import gov.nhtsa.mmucc.auth.dto.LoginRequest;
import gov.nhtsa.mmucc.auth.dto.TokenResponse;
import gov.nhtsa.mmucc.auth.dto.UserSummaryResponse;
import gov.nhtsa.mmucc.auth.mapper.UserMapper;
import gov.nhtsa.mmucc.auth.repository.AppUserRepository;
import gov.nhtsa.mmucc.auth.service.AuthService;
import gov.nhtsa.mmucc.auth.service.AuthService.LoginResult;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;

@RestController
@RequestMapping("/auth")
@Tag(name = "Authentication")
public class AuthController {

    private static final String REFRESH_COOKIE = "mmucc-refresh-token";

    private final AuthService authService;
    private final AppUserRepository userRepository;
    private final UserMapper userMapper;

    public AuthController(AuthService authService, AppUserRepository userRepository,
                          UserMapper userMapper) {
        this.authService = authService;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @PostMapping("/login")
    @SecurityRequirements // No auth required
    @Operation(summary = "Exchange a Firebase ID token for an internal JWT")
    public ResponseEntity<TokenResponse> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {

        String ip = extractClientIp(httpRequest);
        String session = httpRequest.getSession(false) != null
                ? httpRequest.getSession(false).getId() : null;

        LoginResult result = authService.login(request.firebaseIdToken(), ip, session);

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, buildRefreshCookie(result.rawRefreshToken()).toString())
                .body(result.tokenResponse());
    }

    @PostMapping("/refresh")
    @SecurityRequirements
    @Operation(summary = "Issue a new access token using the HttpOnly refresh token cookie")
    public ResponseEntity<TokenResponse> refresh(
            @CookieValue(name = REFRESH_COOKIE, required = false) String rawRefreshToken) {

        if (rawRefreshToken == null || rawRefreshToken.isBlank()) {
            throw new MmuccException.RefreshTokenExpiredException();
        }

        LoginResult result = authService.refresh(rawRefreshToken);

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, buildRefreshCookie(result.rawRefreshToken()).toString())
                .body(result.tokenResponse());
    }

    @PostMapping("/logout")
    @Operation(summary = "Invalidate the refresh token and clear the cookie")
    public ResponseEntity<Void> logout(
            @AuthenticationPrincipal UserPrincipal principal,
            HttpServletRequest httpRequest) {

        String ip = extractClientIp(httpRequest);
        String session = httpRequest.getSession(false) != null
                ? httpRequest.getSession(false).getId() : null;

        authService.logout(principal, ip, session);

        // Expire the cookie immediately
        ResponseCookie expiredCookie = ResponseCookie.from(REFRESH_COOKIE, "")
                .httpOnly(true)
                .secure(true)
                .sameSite("Strict")
                .path("/auth/refresh")
                .maxAge(Duration.ZERO)
                .build();

        return ResponseEntity.noContent()
                .header(HttpHeaders.SET_COOKIE, expiredCookie.toString())
                .build();
    }

    @GetMapping("/me")
    @Operation(summary = "Return the current user's identity from the JWT (no DB lookup)")
    public ResponseEntity<UserSummaryResponse> me(@AuthenticationPrincipal UserPrincipal principal) {
        // Build response from JWT claims — no DB hit needed for this endpoint
        UserSummaryResponse response = userRepository.findById(principal.getUserId())
                .map(userMapper::toSummaryResponse)
                .orElse(new UserSummaryResponse(
                        principal.getUserId(), principal.getUsername(), principal.getEmail(),
                        null, null, principal.getRole(), principal.getAgencyCode(), null));
        return ResponseEntity.ok(response);
    }

    // -----------------------------------------------------------------------

    private ResponseCookie buildRefreshCookie(String rawToken) {
        return ResponseCookie.from(REFRESH_COOKIE, rawToken)
                .httpOnly(true)
                .secure(true)
                .sameSite("Strict")
                .path("/auth/refresh")   // Cookie is only sent to /auth/refresh
                .maxAge(Duration.ofDays(7))
                .build();
    }

    private String extractClientIp(HttpServletRequest request) {
        String forwarded = request.getHeader("X-Forwarded-For");
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        return request.getRemoteAddr();
    }
}
