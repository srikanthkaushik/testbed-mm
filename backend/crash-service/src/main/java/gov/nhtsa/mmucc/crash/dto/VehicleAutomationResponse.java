package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDateTime;
import java.util.List;

public record VehicleAutomationResponse(
        Long id,
        Long vehicleId,
        Long crashId,
        Integer automationPresentCode,
        List<ChildCodeDto> levelsInVehicle,
        List<ChildCodeDto> levelsEngaged,
        LocalDateTime createdDt,
        LocalDateTime modifiedDt
) {}
