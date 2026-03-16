package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.NonMotoristRequest;
import gov.nhtsa.mmucc.crash.entity.NonMotorist;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface NonMotoristMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(NonMotoristRequest request, @MappingTarget NonMotorist nonMotorist);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    NonMotorist toEntity(NonMotoristRequest request);
}
