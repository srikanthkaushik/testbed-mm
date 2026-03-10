package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDateTime;
import java.util.List;

public record VehicleResponse(
        Long vehicleId,
        Long crashId,
        String vin,
        Integer unitTypeCode,
        Integer unitNumber,
        String registrationState,
        Integer registrationYear,
        String licensePlate,
        String make,
        Integer modelYear,
        String model,
        Integer bodyTypeCode,
        Integer trailingUnitsCount,
        Integer vehicleSizeCode,
        Integer hmPlacardFlg,
        Integer totalOccupants,
        Integer specialFunctionCode,
        Integer emergencyUseCode,
        Integer speedLimitMph,
        Integer directionOfTravelCode,
        Integer trafficwayTravelDirCode,
        Integer trafficwayDividedCode,
        Integer trafficwayBarrierCode,
        Integer trafficwayHovHotCode,
        Integer trafficwayHovCrashFlg,
        Integer totalThroughLanes,
        Integer totalAuxiliaryLanes,
        Integer roadwayAlignmentCode,
        Integer roadwayGradeCode,
        Integer maneuverCode,
        Integer damageInitialContact,
        Integer damageExtentCode,
        Integer mostHarmfulEventCode,
        Integer hitAndRunCode,
        Integer towedCode,
        Integer contributingCircCode,

        // Multi-value children
        List<TrafficControlDto> trafficControls,
        List<ChildCodeDto> damageAreas,
        List<ChildCodeDto> sequenceEvents,

        // Audit
        LocalDateTime createdDt,
        LocalDateTime modifiedDt
) {}
