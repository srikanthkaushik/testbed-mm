package gov.nhtsa.mmucc.common.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

/**
 * Stateless JWT utility for generating and validating internal access tokens.
 * Not a Spring bean — instantiated by each service via a @Bean factory method
 * to inject the signing key and configuration from that service's properties.
 */
public class JwtUtils {

    private final SecretKey signingKey;
    private final long accessTokenExpirationMs;
    private final String issuer;

    public JwtUtils(String base64Secret, long accessTokenExpirationMs, String issuer) {
        this.signingKey = Keys.hmacShaKeyFor(Decoders.BASE64.decode(base64Secret));
        this.accessTokenExpirationMs = accessTokenExpirationMs;
        this.issuer = issuer;
    }

    /**
     * Generates an internal access JWT embedding all identity claims.
     * Claim layout:
     * <pre>
     *   sub   = userId (String)
     *   uid   = firebaseUid
     *   uname = username
     *   email = email
     *   role  = roleCode
     *   agency = agencyCode (omitted if null)
     *   iss   = issuer
     *   jti   = random UUID (for future blocklist support)
     * </pre>
     */
    public String generateAccessToken(Long userId, String firebaseUid, String username,
                                      String email, String role, String agencyCode) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + accessTokenExpirationMs);

        var builder = Jwts.builder()
                .subject(String.valueOf(userId))
                .claim("uid", firebaseUid)
                .claim("uname", username)
                .claim("email", email)
                .claim("role", role)
                .issuer(issuer)
                .id(UUID.randomUUID().toString())
                .issuedAt(now)
                .expiration(expiry)
                .signWith(signingKey);

        if (agencyCode != null) {
            builder.claim("agency", agencyCode);
        }

        return builder.compact();
    }

    /**
     * Validates the token signature and expiry, then returns the parsed claims.
     *
     * @throws JwtException if the token is invalid, expired, or tampered with
     */
    public Claims validateAndParseToken(String token) {
        return Jwts.parser()
                .verifyWith(signingKey)
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    /**
     * Extracts the subject (userId) from a token without full validation.
     * Use only for logging/debugging. Always call {@link #validateAndParseToken} first.
     */
    public String extractSubject(String token) {
        return validateAndParseToken(token).getSubject();
    }

    public long getAccessTokenExpirationMs() {
        return accessTokenExpirationMs;
    }
}
