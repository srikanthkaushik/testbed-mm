package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.service.CrashService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/crashes")
@Tag(name = "Crashes", description = "MMUCC crash record management")
@SecurityRequirement(name = "bearerAuth")
public class CrashController {

    private final CrashService crashService;

    public CrashController(CrashService crashService) {
        this.crashService = crashService;
    }

    @GetMapping
    @Operation(summary = "List crashes with optional filters")
    public Page<CrashSummaryResponse> listCrashes(@Valid CrashSearchFilter filter) {
        return crashService.listCrashes(filter);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get full crash detail by ID")
    public CrashDetailResponse getCrash(@PathVariable Long id) {
        return crashService.getCrash(id);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Create a new crash record")
    public CrashDetailResponse createCrash(@Valid @RequestBody CrashRequest request,
                                           @AuthenticationPrincipal UserPrincipal actor) {
        return crashService.createCrash(request, actor);
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Replace a crash record")
    public CrashDetailResponse updateCrash(@PathVariable Long id,
                                           @Valid @RequestBody CrashRequest request,
                                           @AuthenticationPrincipal UserPrincipal actor) {
        return crashService.updateCrash(id, request, actor);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a crash record and all children")
    public void deleteCrash(@PathVariable Long id,
                            @AuthenticationPrincipal UserPrincipal actor) {
        crashService.deleteCrash(id, actor);
    }
}
