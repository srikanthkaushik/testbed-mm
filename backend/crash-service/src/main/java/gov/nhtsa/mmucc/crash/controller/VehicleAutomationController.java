package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.VehicleAutomationRequest;
import gov.nhtsa.mmucc.crash.dto.VehicleAutomationResponse;
import gov.nhtsa.mmucc.crash.service.VehicleAutomationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/crashes/{crashId}/vehicles/{vehicleId}/automation")
@Tag(name = "Vehicle Automation", description = "Vehicle automation (DV1) section for a vehicle")
@SecurityRequirement(name = "bearerAuth")
public class VehicleAutomationController {

    private final VehicleAutomationService vehicleAutomationService;

    public VehicleAutomationController(VehicleAutomationService vehicleAutomationService) {
        this.vehicleAutomationService = vehicleAutomationService;
    }

    @GetMapping
    @Operation(summary = "Get vehicle automation section")
    public VehicleAutomationResponse getAutomation(@PathVariable Long crashId,
                                                    @PathVariable Long vehicleId) {
        return vehicleAutomationService.getAutomation(crashId, vehicleId);
    }

    @PutMapping
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Upsert vehicle automation section")
    public VehicleAutomationResponse upsertAutomation(@PathVariable Long crashId,
                                                       @PathVariable Long vehicleId,
                                                       @Valid @RequestBody VehicleAutomationRequest request,
                                                       @AuthenticationPrincipal UserPrincipal actor) {
        return vehicleAutomationService.upsertAutomation(crashId, vehicleId, request, actor);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete vehicle automation section")
    public void deleteAutomation(@PathVariable Long crashId,
                                 @PathVariable Long vehicleId,
                                 @AuthenticationPrincipal UserPrincipal actor) {
        vehicleAutomationService.deleteAutomation(crashId, vehicleId, actor);
    }
}
