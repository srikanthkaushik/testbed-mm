package gov.nhtsa.mmucc.auth.dto;

/**
 * Response body for successful login and token refresh.
 * The refresh token is NOT included here — it travels as an HttpOnly cookie.
 */
public record TokenResponse(
        String accessToken,
        long expiresIn,       // seconds until access token expiry
        String tokenType,     // always "Bearer"
        UserSummaryResponse user
) {}
