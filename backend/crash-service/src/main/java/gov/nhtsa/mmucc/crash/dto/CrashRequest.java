package gov.nhtsa.mmucc.crash.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

/**
 * Request body for POST /crashes (create) and PUT /crashes/{id} (full replace).
 * All scalar fields are optional — a crash can be created as a minimal shell.
 * Multi-value children: if the list is null, existing children are cleared.
 * Provide items to set/replace children.
 */
public record CrashRequest(
        String crashIdentifier,
        Integer crashTypeCode,
        Integer firstHarmfulEventCode,
        LocalDate crashDate,
        LocalTime crashTime,
        String countyFipsCode,
        String countyName,
        String cityPlaceCode,
        String cityPlaceName,
        String routeId,
        Integer routeTypeCode,
        Integer routeDirectionCode,
        BigDecimal distanceFromRefMiles,
        Integer refPointDirectionCode,
        BigDecimal latitude,
        BigDecimal longitude,
        Integer locFirstHarmfulEvent,
        Integer mannerCollisionCode,
        Integer sourceOfInfoCode,
        Integer lightConditionCode,
        Integer junctionInterchangeFlg,
        Integer junctionLocationCode,
        Integer intersectionApproaches,
        Integer intersectionGeometryCode,
        Integer intersectionTrafficCtl,
        Integer schoolBusRelatedCode,
        Integer workZoneRelatedCode,
        Integer workZoneLocationCode,
        Integer workZoneTypeCode,
        Integer workZoneWorkersCode,
        Integer workZoneLawEnfCode,
        Integer crashSeverityCode,
        Integer numMotorVehicles,
        Integer numMotorists,
        Integer numNonMotorists,
        Integer numNonFatallyInjured,
        Integer numFatalities,
        Integer alcoholInvolvementCode,
        Integer drugInvolvementCode,
        Integer dayOfWeekCode,

        // Multi-value children (null = clear existing; provide items to set)
        List<ChildCodeDto> weatherConditions,
        List<ChildCodeDto> surfaceConditions,
        List<ChildCodeDto> contributingCircumstances
) {}
