package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDateTime;

public record FatalSectionResponse(
        Long id,
        Long personId,
        Long crashId,
        Integer avoidanceManeuverCode,
        Integer alcoholTestTypeCode,
        String alcoholTestResult,
        Integer drugTestTypeCode,
        Integer drugTestResult,
        LocalDateTime createdDt,
        LocalDateTime modifiedDt
) {}
