package gov.nhtsa.mmucc.crash.dto;

/** Request body for PUT /persons/{id}/fatal */
public record FatalSectionRequest(
        Integer avoidanceManeuverCode,
        Integer alcoholTestTypeCode,
        String alcoholTestResult,
        Integer drugTestTypeCode,
        Integer drugTestResult
) {}
