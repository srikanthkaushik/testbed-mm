package gov.nhtsa.mmucc.crash.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/**
 * Reusable DTO for multi-value child tables that hold a sequence number and one code.
 * Used for: weather conditions, surface conditions, contributing circumstances,
 * vehicle damage areas, and vehicle sequence events.
 */
public record ChildCodeDto(
        @NotNull @Min(1) Integer sequenceNum,
        @NotNull Integer code
) {}
