package gov.nhtsa.mmucc.crash.config;

import gov.nhtsa.mmucc.common.dto.ErrorResponse;
import gov.nhtsa.mmucc.crash.security.JwtAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtFilter;
    private final ObjectMapper objectMapper;

    @Value("${mmucc.cors.allowed-origins:http://localhost:4200}")
    private List<String> allowedOrigins;

    public SecurityConfig(JwtAuthenticationFilter jwtFilter, ObjectMapper objectMapper) {
        this.jwtFilter = jwtFilter;
        this.objectMapper = objectMapper;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .requestMatchers("/swagger-ui/**", "/swagger-ui.html",
                                 "/v3/api-docs/**", "/v3/api-docs").permitAll()
                // Read access: any authenticated user
                .requestMatchers(HttpMethod.GET, "/crashes/**").authenticated()
                // Write access: DATA_ENTRY and ADMIN
                .requestMatchers(HttpMethod.POST, "/crashes/**")
                    .hasAnyRole("ADMIN", "DATA_ENTRY")
                .requestMatchers(HttpMethod.PUT, "/crashes/**")
                    .hasAnyRole("ADMIN", "DATA_ENTRY")
                // Delete: ADMIN only
                .requestMatchers(HttpMethod.DELETE, "/crashes/**").hasRole("ADMIN")
                .requestMatchers("/actuator/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((req, res, e) -> {
                    res.setStatus(401);
                    res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    res.getWriter().write(objectMapper.writeValueAsString(
                            ErrorResponse.of(401, "Unauthorized", e.getMessage(), req.getRequestURI())));
                })
                .accessDeniedHandler((req, res, e) -> {
                    // Anonymous users (expired/missing token) should get 401 so the
                    // Angular interceptor's refresh-and-retry logic is triggered.
                    // Authenticated users who lack the required role get 403.
                    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
                    boolean isAnonymous = auth == null || auth instanceof AnonymousAuthenticationToken;
                    if (isAnonymous) {
                        res.setStatus(401);
                        res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                        res.getWriter().write(objectMapper.writeValueAsString(
                                ErrorResponse.of(401, "Unauthorized", "Authentication required", req.getRequestURI())));
                    } else {
                        res.setStatus(403);
                        res.setContentType(MediaType.APPLICATION_JSON_VALUE);
                        res.getWriter().write(objectMapper.writeValueAsString(
                                ErrorResponse.of(403, "Forbidden", e.getMessage(), req.getRequestURI())));
                    }
                })
            )
            .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(allowedOrigins);
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
