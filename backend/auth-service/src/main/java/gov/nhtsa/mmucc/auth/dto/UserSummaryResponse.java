package gov.nhtsa.mmucc.auth.dto;

/**
 * User identity summary returned in login/refresh responses and GET /auth/me.
 */
public record UserSummaryResponse(
        Long userId,
        String username,
        String email,
        String firstName,
        String lastName,
        String roleCode,
        String agencyCode,
        String agencyName,
        boolean active
) {}
