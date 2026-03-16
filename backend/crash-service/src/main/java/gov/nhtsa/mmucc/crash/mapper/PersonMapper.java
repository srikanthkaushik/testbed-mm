package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.PersonRequest;
import gov.nhtsa.mmucc.crash.entity.Person;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface PersonMapper {

    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(PersonRequest request, @MappingTarget Person person);

    @Mapping(target = "personId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    Person toEntity(PersonRequest request);
}
