package gov.nhtsa.mmucc.auth.controller;

import gov.nhtsa.mmucc.auth.dto.CreateUserRequest;
import gov.nhtsa.mmucc.auth.dto.UpdateUserRoleRequest;
import gov.nhtsa.mmucc.auth.dto.UpdateUserStatusRequest;
import gov.nhtsa.mmucc.auth.dto.UserSummaryResponse;
import gov.nhtsa.mmucc.auth.service.UserAdminService;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.net.URI;

@RestController
@RequestMapping("/admin/users")
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "User Administration")
public class AdminUserController {

    private final UserAdminService userAdminService;

    public AdminUserController(UserAdminService userAdminService) {
        this.userAdminService = userAdminService;
    }

    @PostMapping
    @Operation(summary = "Pre-provision a user account (Firebase account must exist first)")
    public ResponseEntity<UserSummaryResponse> createUser(
            @Valid @RequestBody CreateUserRequest request,
            @AuthenticationPrincipal UserPrincipal actor) {

        UserSummaryResponse created = userAdminService.createUser(request, actor);
        return ResponseEntity
                .created(URI.create("/admin/users/" + created.userId()))
                .body(created);
    }

    @GetMapping
    @Operation(summary = "List users with optional role filter and pagination")
    public ResponseEntity<Page<UserSummaryResponse>> listUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            @RequestParam(required = false) String role) {

        return ResponseEntity.ok(userAdminService.listUsers(page, size, role));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get a user by ID")
    public ResponseEntity<UserSummaryResponse> getUserById(@PathVariable Long id) {
        return ResponseEntity.ok(userAdminService.getUserById(id));
    }

    @PutMapping("/{id}/role")
    @Operation(summary = "Update a user's role")
    public ResponseEntity<UserSummaryResponse> updateRole(
            @PathVariable Long id,
            @Valid @RequestBody UpdateUserRoleRequest request,
            @AuthenticationPrincipal UserPrincipal actor) {

        return ResponseEntity.ok(userAdminService.updateRole(id, request, actor));
    }

    @PutMapping("/{id}/status")
    @Operation(summary = "Activate or deactivate a user account")
    public ResponseEntity<UserSummaryResponse> updateStatus(
            @PathVariable Long id,
            @RequestBody UpdateUserStatusRequest request,
            @AuthenticationPrincipal UserPrincipal actor) {

        return ResponseEntity.ok(userAdminService.updateStatus(id, request, actor));
    }
}
