package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.VehicleRequest;
import gov.nhtsa.mmucc.crash.entity.Vehicle;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface VehicleMapper {

    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(VehicleRequest request, @MappingTarget Vehicle vehicle);

    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    Vehicle toEntity(VehicleRequest request);
}
