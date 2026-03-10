package gov.nhtsa.mmucc.crash.dto;

import java.math.BigDecimal;

/** Request body for POST /crashes/{id}/roadway and PUT /crashes/{id}/roadway. */
public record RoadwayRequest(
        String bridgeStructureId,
        BigDecimal curveRadiusFt,
        BigDecimal curveLengthFt,
        BigDecimal curveSuperelevationPct,
        String gradeDirection,
        BigDecimal gradePercent,
        Integer nationalHwySysCode,
        Integer functionalClassCode,
        Integer aadtYear,
        Integer aadtValue,
        String aadtTruckMeasure,
        String aadtMotorcycleMeasure,
        BigDecimal laneWidthFt,
        BigDecimal leftShoulderWidthFt,
        BigDecimal rightShoulderWidthFt,
        BigDecimal medianWidthFt,
        Integer accessControlCode,
        String railwayCrossingId,
        Integer roadwayLightingCode,
        Integer pavementEdgelineCode,
        Integer pavementCenterlineCode,
        Integer pavementLaneLineCode,
        Integer bicycleFacilityCode,
        Integer bicycleSignedRouteCode,
        Integer mainlineLanesCount,
        Integer crossStreetLanesCount,
        Integer enteringVehiclesYear,
        Integer enteringVehiclesAadt
) {}
