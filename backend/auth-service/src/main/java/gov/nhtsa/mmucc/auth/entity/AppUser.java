package gov.nhtsa.mmucc.auth.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "APP_USER_TBL")
@Getter
@Setter
public class AppUser {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "AUS_USER_ID")
    private Long userId;

    @Column(name = "AUS_USERNAME", nullable = false, length = 50, unique = true)
    private String username;

    @Column(name = "AUS_EMAIL", nullable = false, length = 150, unique = true)
    private String email;

    /** Nullable: Firebase users do not have a locally-managed password. */
    @Column(name = "AUS_PASSWORD_HASH", length = 255)
    private String passwordHash;

    /** Firebase Authentication UID — primary linkage between Firebase and this app. */
    @Column(name = "AUS_FIREBASE_UID", length = 128, unique = true)
    private String firebaseUid;

    /** Role codes: ADMIN, DATA_ENTRY, ANALYST, VIEWER */
    @Column(name = "AUS_ROLE_CODE", nullable = false, length = 20)
    private String roleCode;

    @Column(name = "AUS_AGENCY_CODE", length = 20)
    private String agencyCode;

    @Column(name = "AUS_AGENCY_NAME", length = 150)
    private String agencyName;

    @Column(name = "AUS_FIRST_NAME", length = 75)
    private String firstName;

    @Column(name = "AUS_LAST_NAME", length = 75)
    private String lastName;

    @Column(name = "AUS_IS_ACTIVE_FLG", nullable = false, columnDefinition = "TINYINT(1)")
    private boolean active = true;

    @Column(name = "AUS_LAST_LOGIN_DT")
    private LocalDateTime lastLoginDt;

    @Column(name = "AUS_FAILED_LOGIN_COUNT", nullable = false)
    private int failedLoginCount = 0;

    @Column(name = "AUS_ACCOUNT_LOCKED_FLG", nullable = false, columnDefinition = "TINYINT(1)")
    private boolean accountLocked = false;

    @Column(name = "AUS_PASSWORD_RESET_TOKEN", length = 255)
    private String passwordResetToken;

    @Column(name = "AUS_PASSWORD_RESET_EXPIRY")
    private LocalDateTime passwordResetExpiry;

    /** SHA-256 hex hash of the current refresh token. NULL when logged out. */
    @Column(name = "AUS_REFRESH_TOKEN_HASH", length = 255)
    private String refreshTokenHash;

    @Column(name = "AUS_REFRESH_TOKEN_EXPIRY")
    private LocalDateTime refreshTokenExpiry;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",
            column = @Column(name = "AUS_CREATED_BY", nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",
            column = @Column(name = "AUS_CREATED_DT", nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",
            column = @Column(name = "AUS_MODIFIED_BY", length = 100)),
        @AttributeOverride(name = "modifiedDt",
            column = @Column(name = "AUS_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode",
            column = @Column(name = "AUS_LAST_UPDATED_ACTIVITY_CODE", nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
