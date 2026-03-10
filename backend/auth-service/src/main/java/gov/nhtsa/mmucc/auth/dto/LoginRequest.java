package gov.nhtsa.mmucc.auth.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Request body for POST /auth/login.
 * The frontend obtains this token from Firebase SDK after the user authenticates.
 */
public record LoginRequest(
        @NotBlank(message = "Firebase ID token is required")
        String firebaseIdToken
) {}
