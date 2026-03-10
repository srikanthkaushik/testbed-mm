package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.CrashRequest;
import gov.nhtsa.mmucc.crash.dto.CrashSummaryResponse;
import gov.nhtsa.mmucc.crash.entity.Crash;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface CrashMapper {

    /**
     * Maps scalar crash fields from request onto an existing entity (for PUT).
     * Audit fields and crashId are ignored — service layer manages them.
     */
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(CrashRequest request, @MappingTarget Crash crash);

    /**
     * Maps scalar crash fields from request to a new entity (for POST).
     */
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    Crash toEntity(CrashRequest request);

    /**
     * Lightweight summary for list responses.
     * MapStruct matches entity field names to record component names automatically.
     */
    @Mapping(target = "createdDt", source = "audit.createdDt")
    @Mapping(target = "modifiedDt", source = "audit.modifiedDt")
    CrashSummaryResponse toSummary(Crash crash);
}
