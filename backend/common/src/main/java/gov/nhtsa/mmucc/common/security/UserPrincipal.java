package gov.nhtsa.mmucc.common.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * Immutable security principal constructed from validated JWT claims.
 * Carried in SecurityContextHolder for the duration of each request.
 * Does NOT require a database lookup — all identity data is embedded in the JWT.
 */
public final class UserPrincipal implements UserDetails {

    private final Long userId;
    private final String username;
    private final String email;
    private final String firebaseUid;
    private final String role;
    private final String agencyCode;

    public UserPrincipal(Long userId, String username, String email,
                         String firebaseUid, String role, String agencyCode) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.firebaseUid = firebaseUid;
        this.role = role;
        this.agencyCode = agencyCode;
    }

    public Long getUserId() { return userId; }
    public String getEmail() { return email; }
    public String getFirebaseUid() { return firebaseUid; }
    public String getRole() { return role; }
    public String getAgencyCode() { return agencyCode; }

    @Override
    public String getUsername() { return username; }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role));
    }

    @Override
    public String getPassword() { return null; }

    @Override
    public boolean isAccountNonExpired() { return true; }

    @Override
    public boolean isAccountNonLocked() { return true; }

    @Override
    public boolean isCredentialsNonExpired() { return true; }

    @Override
    public boolean isEnabled() { return true; }
}
