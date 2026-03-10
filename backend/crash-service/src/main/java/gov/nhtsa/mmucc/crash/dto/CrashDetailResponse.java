package gov.nhtsa.mmucc.crash.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/** Full crash aggregate: all scalar fields plus all child collections. */
public record CrashDetailResponse(
        Long crashId,
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

        // Multi-value children
        List<ChildCodeDto> weatherConditions,
        List<ChildCodeDto> surfaceConditions,
        List<ChildCodeDto> contributingCircumstances,

        // Related entities
        RoadwayResponse roadway,
        List<VehicleResponse> vehicles,

        // Audit
        String createdBy,
        LocalDateTime createdDt,
        String modifiedBy,
        LocalDateTime modifiedDt
) {}
