package gov.nhtsa.mmucc.crash.dto;

import java.util.List;

/** Request body for PUT /persons/{id}/non-motorist */
public record NonMotoristRequest(
        Integer strikingVehicleUnit,
        Integer actionCircCode,
        Integer originDestinationCode,
        Integer contributingAction1,
        Integer contributingAction2,
        Integer locationAtCrashCode,
        Integer initialContactPoint,
        List<ChildCodeDto> safetyEquipment
) {}
