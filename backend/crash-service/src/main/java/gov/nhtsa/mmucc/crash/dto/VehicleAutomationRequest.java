package gov.nhtsa.mmucc.crash.dto;

import java.util.List;

/** Request body for PUT /vehicles/{id}/automation */
public record VehicleAutomationRequest(
        Integer automationPresentCode,
        List<ChildCodeDto> levelsInVehicle,
        List<ChildCodeDto> levelsEngaged
) {}
