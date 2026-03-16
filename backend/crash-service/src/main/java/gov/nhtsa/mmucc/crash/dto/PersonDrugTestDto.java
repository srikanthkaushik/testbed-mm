package gov.nhtsa.mmucc.crash.dto;

/** DTO for a single drug test result entry (P23 SF3). */
public record PersonDrugTestDto(
        Integer sequenceNum,
        Integer resultCode
) {}
