package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.RoadwayRequest;
import gov.nhtsa.mmucc.crash.dto.RoadwayResponse;
import gov.nhtsa.mmucc.crash.service.RoadwayService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/crashes/{crashId}/roadway")
@Tag(name = "Roadway", description = "Roadway data for a crash (1:1 relationship)")
@SecurityRequirement(name = "bearerAuth")
public class RoadwayController {

    private final RoadwayService roadwayService;

    public RoadwayController(RoadwayService roadwayService) {
        this.roadwayService = roadwayService;
    }

    @GetMapping
    @Operation(summary = "Get roadway data for a crash")
    public RoadwayResponse getRoadway(@PathVariable Long crashId) {
        return roadwayService.getRoadway(crashId);
    }

    @PutMapping
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Create or replace roadway data for a crash")
    public RoadwayResponse upsertRoadway(@PathVariable Long crashId,
                                         @Valid @RequestBody RoadwayRequest request,
                                         @AuthenticationPrincipal UserPrincipal actor) {
        return roadwayService.upsertRoadway(crashId, request, actor);
    }

    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete roadway data for a crash")
    public void deleteRoadway(@PathVariable Long crashId,
                              @AuthenticationPrincipal UserPrincipal actor) {
        roadwayService.deleteRoadway(crashId, actor);
    }
}
