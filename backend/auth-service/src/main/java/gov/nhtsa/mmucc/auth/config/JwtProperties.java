package gov.nhtsa.mmucc.auth.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mmucc.jwt")
public class JwtProperties {

    /** Base64-encoded HMAC-SHA256 key. Minimum 256 bits. Injected from env var MMUCC_JWT_SECRET. */
    private String secret;

    /** Access token lifespan in milliseconds. Default: 15 minutes. */
    private long accessTokenExpirationMs = 900_000L;

    /** Refresh token lifespan in days. Default: 7 days. */
    private int refreshTokenExpirationDays = 7;

    /** JWT issuer claim. */
    private String issuer = "mmucc-auth-service";

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }

    public long getAccessTokenExpirationMs() { return accessTokenExpirationMs; }
    public void setAccessTokenExpirationMs(long accessTokenExpirationMs) {
        this.accessTokenExpirationMs = accessTokenExpirationMs;
    }

    public int getRefreshTokenExpirationDays() { return refreshTokenExpirationDays; }
    public void setRefreshTokenExpirationDays(int refreshTokenExpirationDays) {
        this.refreshTokenExpirationDays = refreshTokenExpirationDays;
    }

    public String getIssuer() { return issuer; }
    public void setIssuer(String issuer) { this.issuer = issuer; }
}
