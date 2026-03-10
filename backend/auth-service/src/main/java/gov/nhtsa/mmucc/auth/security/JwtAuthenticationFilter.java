package gov.nhtsa.mmucc.auth.security;

import gov.nhtsa.mmucc.common.security.JwtUtils;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * Validates the internal JWT on every request and populates SecurityContextHolder.
 * Does NOT hit the database — all identity is extracted from the JWT claims.
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(JwtAuthenticationFilter.class);
    private static final String BEARER_PREFIX = "Bearer ";

    private final JwtUtils jwtUtils;

    public JwtAuthenticationFilter(JwtUtils jwtUtils) {
        this.jwtUtils = jwtUtils;
    }

    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain)
            throws ServletException, IOException {

        String authHeader = request.getHeader(HttpHeaders.AUTHORIZATION);

        if (authHeader == null || !authHeader.startsWith(BEARER_PREFIX)) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(BEARER_PREFIX.length());

        try {
            Claims claims = jwtUtils.validateAndParseToken(token);
            UserPrincipal principal = claimsToPrincipal(claims);

            UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(principal, null, principal.getAuthorities());
            authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

            SecurityContextHolder.getContext().setAuthentication(authentication);

        } catch (JwtException e) {
            log.debug("JWT validation failed: {}", e.getMessage());
            // Do not set authentication — Spring Security will reject the request
            // at the authorization layer if the endpoint requires authentication.
        }

        filterChain.doFilter(request, response);
    }

    private UserPrincipal claimsToPrincipal(Claims claims) {
        Long userId = Long.parseLong(claims.getSubject());
        String firebaseUid = claims.get("uid", String.class);
        String username = claims.get("uname", String.class);
        String email = claims.get("email", String.class);
        String role = claims.get("role", String.class);
        String agencyCode = claims.get("agency", String.class);
        return new UserPrincipal(userId, username, email, firebaseUid, role, agencyCode);
    }
}
