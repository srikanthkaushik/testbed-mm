package gov.nhtsa.mmucc.crash.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/** Lightweight projection returned in paginated crash lists. */
public record CrashSummaryResponse(
        Long crashId,
        String crashIdentifier,
        LocalDate crashDate,
        LocalTime crashTime,
        String countyFipsCode,
        String countyName,
        String cityPlaceName,
        Integer crashSeverityCode,
        Integer numMotorVehicles,
        Integer numFatalities,
        LocalDateTime createdDt,
        LocalDateTime modifiedDt
) {}
