package gov.nhtsa.mmucc.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Admin request to pre-provision a user account.
 * The user's Firebase account must already exist before calling this endpoint.
 */
public record CreateUserRequest(
        @NotBlank @Size(max = 50) String username,
        @NotBlank @Email @Size(max = 150) String email,
        @NotBlank @Size(max = 128) String firebaseUid,
        @NotBlank String roleCode,
        @Size(max = 20) String agencyCode,
        @Size(max = 150) String agencyName,
        @Size(max = 75) String firstName,
        @Size(max = 75) String lastName
) {}
