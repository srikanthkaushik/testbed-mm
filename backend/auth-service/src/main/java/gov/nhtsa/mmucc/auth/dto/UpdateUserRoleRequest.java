package gov.nhtsa.mmucc.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateUserRoleRequest(
        @NotBlank String roleCode
) {}
