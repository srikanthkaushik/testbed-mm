package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.LargeVehicleRequest;
import gov.nhtsa.mmucc.crash.dto.LargeVehicleResponse;
import gov.nhtsa.mmucc.crash.service.LargeVehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/crashes/{crashId}/vehicles/{vehicleId}/large-vehicle")
@Tag(name = "Large Vehicle", description = "Large vehicle section for a vehicle in a crash")
@SecurityRequirement(name = "bearerAuth")
public class LargeVehicleController {

    private final LargeVehicleService largeVehicleService;

    public LargeVehicleController(LargeVehicleService largeVehicleService) {
        this.largeVehicleService = largeVehicleService;
    }

    @GetMapping
    @Operation(summary = "Get large vehicle section")
    public LargeVehicleResponse getLargeVehicle(@PathVariable Long crashId,
                                                 @PathVariable Long vehicleId) {
        return largeVehicleService.getLargeVehicle(crashId, vehicleId);
    }

    @PutMapping
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Upsert large vehicle section")
    public LargeVehicleResponse upsertLargeVehicle(@PathVariable Long crashId,
                                                    @PathVariable Long vehicleId,
                                                    @Valid @RequestBody LargeVehicleRequest request,
                                                    @AuthenticationPrincipal UserPrincipal actor) {
        return largeVehicleService.upsertLargeVehicle(crashId, vehicleId, request, actor);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete large vehicle section")
    public void deleteLargeVehicle(@PathVariable Long crashId,
                                   @PathVariable Long vehicleId,
                                   @AuthenticationPrincipal UserPrincipal actor) {
        largeVehicleService.deleteLargeVehicle(crashId, vehicleId, actor);
    }
}
