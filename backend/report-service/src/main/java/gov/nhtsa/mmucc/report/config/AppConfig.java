package gov.nhtsa.mmucc.report.config;

import gov.nhtsa.mmucc.common.security.JwtUtils;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfig {

    @Bean
    public JwtUtils jwtUtils(JwtProperties props) {
        return new JwtUtils(props.getSecret(), props.getAccessTokenExpirationMs(), props.getIssuer());
    }
}
