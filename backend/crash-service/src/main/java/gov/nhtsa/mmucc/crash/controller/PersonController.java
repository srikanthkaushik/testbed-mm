package gov.nhtsa.mmucc.crash.controller;

import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.service.PersonService;
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
@RequestMapping("/crashes/{crashId}/vehicles/{vehicleId}/persons")
@Tag(name = "Persons", description = "Persons associated with a vehicle in a crash")
@SecurityRequirement(name = "bearerAuth")
public class PersonController {

    private final PersonService personService;

    public PersonController(PersonService personService) {
        this.personService = personService;
    }

    @GetMapping
    @Operation(summary = "List all persons for a vehicle")
    public List<PersonResponse> listPersons(@PathVariable Long crashId,
                                             @PathVariable Long vehicleId) {
        return personService.listPersons(crashId, vehicleId);
    }

    @GetMapping("/{personId}")
    @Operation(summary = "Get a single person")
    public PersonResponse getPerson(@PathVariable Long crashId,
                                    @PathVariable Long vehicleId,
                                    @PathVariable Long personId) {
        return personService.getPerson(crashId, vehicleId, personId);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Add a person to a vehicle")
    public PersonResponse createPerson(@PathVariable Long crashId,
                                       @PathVariable Long vehicleId,
                                       @Valid @RequestBody PersonRequest request,
                                       @AuthenticationPrincipal UserPrincipal actor) {
        return personService.createPerson(crashId, vehicleId, request, actor);
    }

    @PutMapping("/{personId}")
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Replace a person record")
    public PersonResponse updatePerson(@PathVariable Long crashId,
                                       @PathVariable Long vehicleId,
                                       @PathVariable Long personId,
                                       @Valid @RequestBody PersonRequest request,
                                       @AuthenticationPrincipal UserPrincipal actor) {
        return personService.updatePerson(crashId, vehicleId, personId, request, actor);
    }

    @DeleteMapping("/{personId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a person and their children")
    public void deletePerson(@PathVariable Long crashId,
                              @PathVariable Long vehicleId,
                              @PathVariable Long personId,
                              @AuthenticationPrincipal UserPrincipal actor) {
        personService.deletePerson(crashId, vehicleId, personId, actor);
    }

    // -----------------------------------------------------------------------
    // Fatal Section
    // -----------------------------------------------------------------------

    @GetMapping("/{personId}/fatal")
    @Operation(summary = "Get fatal section for a person")
    public FatalSectionResponse getFatalSection(@PathVariable Long crashId,
                                                 @PathVariable Long vehicleId,
                                                 @PathVariable Long personId) {
        return personService.getFatalSection(crashId, vehicleId, personId);
    }

    @PutMapping("/{personId}/fatal")
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Upsert fatal section for a person")
    public FatalSectionResponse upsertFatalSection(@PathVariable Long crashId,
                                                    @PathVariable Long vehicleId,
                                                    @PathVariable Long personId,
                                                    @Valid @RequestBody FatalSectionRequest request,
                                                    @AuthenticationPrincipal UserPrincipal actor) {
        return personService.upsertFatalSection(crashId, vehicleId, personId, request, actor);
    }

    @DeleteMapping("/{personId}/fatal")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete fatal section for a person")
    public void deleteFatalSection(@PathVariable Long crashId,
                                   @PathVariable Long vehicleId,
                                   @PathVariable Long personId,
                                   @AuthenticationPrincipal UserPrincipal actor) {
        personService.deleteFatalSection(crashId, vehicleId, personId, actor);
    }

    // -----------------------------------------------------------------------
    // Non-Motorist Section
    // -----------------------------------------------------------------------

    @GetMapping("/{personId}/non-motorist")
    @Operation(summary = "Get non-motorist section for a person")
    public NonMotoristResponse getNonMotorist(@PathVariable Long crashId,
                                               @PathVariable Long vehicleId,
                                               @PathVariable Long personId) {
        return personService.getNonMotorist(crashId, vehicleId, personId);
    }

    @PutMapping("/{personId}/non-motorist")
    @PreAuthorize("hasAnyRole('ADMIN','DATA_ENTRY')")
    @Operation(summary = "Upsert non-motorist section for a person")
    public NonMotoristResponse upsertNonMotorist(@PathVariable Long crashId,
                                                  @PathVariable Long vehicleId,
                                                  @PathVariable Long personId,
                                                  @Valid @RequestBody NonMotoristRequest request,
                                                  @AuthenticationPrincipal UserPrincipal actor) {
        return personService.upsertNonMotorist(crashId, vehicleId, personId, request, actor);
    }

    @DeleteMapping("/{personId}/non-motorist")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete non-motorist section for a person")
    public void deleteNonMotorist(@PathVariable Long crashId,
                                  @PathVariable Long vehicleId,
                                  @PathVariable Long personId,
                                  @AuthenticationPrincipal UserPrincipal actor) {
        personService.deleteNonMotorist(crashId, vehicleId, personId, actor);
    }
}
