package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.RoadwayRequest;
import gov.nhtsa.mmucc.crash.entity.Roadway;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface RoadwayMapper {

    @Mapping(target = "roadwayId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(RoadwayRequest request, @MappingTarget Roadway roadway);

    @Mapping(target = "roadwayId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    Roadway toEntity(RoadwayRequest request);
}
