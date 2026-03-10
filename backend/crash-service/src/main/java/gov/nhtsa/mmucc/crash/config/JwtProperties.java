package gov.nhtsa.mmucc.crash.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "mmucc.jwt")
public class JwtProperties {

    private String secret;
    private long accessTokenExpirationMs = 900_000L;
    private String issuer = "mmucc-auth-service";

    public String getSecret() { return secret; }
    public void setSecret(String secret) { this.secret = secret; }

    public long getAccessTokenExpirationMs() { return accessTokenExpirationMs; }
    public void setAccessTokenExpirationMs(long ms) { this.accessTokenExpirationMs = ms; }

    public String getIssuer() { return issuer; }
    public void setIssuer(String issuer) { this.issuer = issuer; }
}
