package gov.nhtsa.mmucc.reference.controller;

import gov.nhtsa.mmucc.reference.dto.LookupEntryDto;
import gov.nhtsa.mmucc.reference.service.LookupService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

@RestController
@RequestMapping("/lookups")
@Tag(name = "Lookups", description = "MMUCC coded-value reference data (read-only)")
public class LookupController {

    private final LookupService lookupService;

    public LookupController(LookupService lookupService) {
        this.lookupService = lookupService;
    }

    /**
     * Returns all 7 lookup types in a single response.
     * Use this at application startup to pre-load the full reference dataset.
     */
    @GetMapping
    @Operation(summary = "Get all lookup types",
               description = "Returns crash-types, harmful-events, weather-conditions, " +
                             "surface-conditions, person-types, injury-statuses, body-types")
    public ResponseEntity<Map<String, List<LookupEntryDto>>> getAll() {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(24, TimeUnit.HOURS).cachePublic())
                .body(lookupService.getAll());
    }

    /**
     * Returns entries for a single lookup type.
     *
     * @param type One of: crash-types, harmful-events, weather-conditions,
     *             surface-conditions, person-types, injury-statuses, body-types
     */
    @GetMapping("/{type}")
    @Operation(summary = "Get a single lookup type")
    public ResponseEntity<List<LookupEntryDto>> getByType(
            @Parameter(description = "Lookup type name", example = "injury-statuses")
            @PathVariable String type) {
        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(24, TimeUnit.HOURS).cachePublic())
                .body(lookupService.getByType(type));
    }
}
