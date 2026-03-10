package gov.nhtsa.mmucc.auth.mapper;

import gov.nhtsa.mmucc.auth.dto.CreateUserRequest;
import gov.nhtsa.mmucc.auth.dto.UserSummaryResponse;
import gov.nhtsa.mmucc.auth.entity.AppUser;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "spring")
public interface UserMapper {

    @Mapping(target = "userId", source = "userId")
    UserSummaryResponse toSummaryResponse(AppUser user);

    /** Maps a create request to a new entity. Audit fields and ID must be set by the service. */
    @Mapping(target = "userId", ignore = true)
    @Mapping(target = "audit", ignore = true)
    @Mapping(target = "active", constant = "true")
    @Mapping(target = "accountLocked", constant = "false")
    @Mapping(target = "failedLoginCount", constant = "0")
    @Mapping(target = "lastLoginDt", ignore = true)
    @Mapping(target = "passwordHash", ignore = true)
    @Mapping(target = "passwordResetToken", ignore = true)
    @Mapping(target = "passwordResetExpiry", ignore = true)
    @Mapping(target = "refreshTokenHash", ignore = true)
    @Mapping(target = "refreshTokenExpiry", ignore = true)
    AppUser fromCreateRequest(CreateUserRequest request);
}
