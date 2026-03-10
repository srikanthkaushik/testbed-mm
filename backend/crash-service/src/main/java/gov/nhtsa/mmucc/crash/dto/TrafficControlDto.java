package gov.nhtsa.mmucc.crash.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

/** DTO for VEHICLE_TRAFFIC_CONTROL_TBL — two code fields plus sequence number. */
public record TrafficControlDto(
        @NotNull @Min(1) Integer sequenceNum,
        @NotNull Integer tcdTypeCode,
        Integer tcdInoperativeCode   // nullable
) {}
