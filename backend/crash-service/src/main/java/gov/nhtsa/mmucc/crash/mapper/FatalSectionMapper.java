package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.FatalSectionRequest;
import gov.nhtsa.mmucc.crash.entity.FatalSection;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface FatalSectionMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(FatalSectionRequest request, @MappingTarget FatalSection fatalSection);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    FatalSection toEntity(FatalSectionRequest request);
}
