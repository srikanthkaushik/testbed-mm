package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.LargeVehicleRequest;
import gov.nhtsa.mmucc.crash.entity.LargeVehicle;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface LargeVehicleMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(LargeVehicleRequest request, @MappingTarget LargeVehicle largeVehicle);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    LargeVehicle toEntity(LargeVehicleRequest request);
}
