package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.VehicleRequest;
import gov.nhtsa.mmucc.crash.dto.VehicleResponse;
import gov.nhtsa.mmucc.crash.service.VehicleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/crashes/{crashId}/vehicles")
@Tag(name = "Vehicles", description = "Vehicles associated with a crash")
@SecurityRequirement(name = "bearerAuth")
public class VehicleController {

    private final VehicleService vehicleService;

    public VehicleController(VehicleService vehicleService) {
        this.vehicleService = vehicleService;
    }

    @GetMapping
    @Operation(summary = "List all vehicles for a crash")
    public List<VehicleResponse> listVehicles(@PathVariable Long crashId) {
        return vehicleService.listVehicles(crashId);
    }

    @GetMapping("/{vehicleId}")
    @Operation(summary = "Get a single vehicle")
    public VehicleResponse getVehicle(@PathVariable Long crashId,
                                      @PathVariable Long vehicleId) {
        return vehicleService.getVehicle(crashId, vehicleId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Add a vehicle to a crash")
    public VehicleResponse createVehicle(@PathVariable Long crashId,
                                         @Valid @RequestBody VehicleRequest request,
                                         @AuthenticationPrincipal UserPrincipal actor) {
        return vehicleService.createVehicle(crashId, request, actor);
    }

    @PutMapping("/{vehicleId}")
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Replace a vehicle record")
    public VehicleResponse updateVehicle(@PathVariable Long crashId,
                                         @PathVariable Long vehicleId,
                                         @Valid @RequestBody VehicleRequest request,
                                         @AuthenticationPrincipal UserPrincipal actor) {
        return vehicleService.updateVehicle(crashId, vehicleId, request, actor);
    }

    @DeleteMapping("/{vehicleId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a vehicle and its children")
    public void deleteVehicle(@PathVariable Long crashId,
                              @PathVariable Long vehicleId,
                              @AuthenticationPrincipal UserPrincipal actor) {
        vehicleService.deleteVehicle(crashId, vehicleId, actor);
    }
}
