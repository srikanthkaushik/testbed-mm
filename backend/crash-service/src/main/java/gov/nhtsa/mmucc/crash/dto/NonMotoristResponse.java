package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDateTime;
import java.util.List;

public record NonMotoristResponse(
        Long id,
        Long personId,
        Long crashId,
        Integer strikingVehicleUnit,
        Integer actionCircCode,
        Integer originDestinationCode,
        Integer contributingAction1,
        Integer contributingAction2,
        Integer locationAtCrashCode,
        Integer initialContactPoint,
        List<ChildCodeDto> safetyEquipment,
        LocalDateTime createdDt,
        LocalDateTime modifiedDt
) {}
