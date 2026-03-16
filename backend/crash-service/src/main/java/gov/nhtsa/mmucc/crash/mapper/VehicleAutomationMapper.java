package gov.nhtsa.mmucc.crash.mapper;

import gov.nhtsa.mmucc.crash.dto.VehicleAutomationRequest;
import gov.nhtsa.mmucc.crash.entity.VehicleAutomation;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface VehicleAutomationMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    void updateEntityFromRequest(VehicleAutomationRequest request, @MappingTarget VehicleAutomation vehicleAutomation);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "vehicleId", ignore = true)
    @Mapping(target = "crashId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    VehicleAutomation toEntity(VehicleAutomationRequest request);
}
