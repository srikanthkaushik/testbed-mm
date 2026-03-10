package gov.nhtsa.mmucc.auth.service;

import java.util.Arrays;

/**
 * Valid role codes for AUS_ROLE_CODE in APP_USER_TBL.
 */
public enum RoleCode {
    ADMIN,
    DATA_ENTRY,
    ANALYST,
    VIEWER;

    public static RoleCode fromString(String code) {
        return Arrays.stream(values())
                .filter(r -> r.name().equalsIgnoreCase(code))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Unknown role code: " + code + ". Valid values: ADMIN, DATA_ENTRY, ANALYST, VIEWER"));
    }
}
