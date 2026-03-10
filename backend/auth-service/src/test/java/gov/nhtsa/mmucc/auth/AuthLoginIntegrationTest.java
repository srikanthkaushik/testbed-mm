package gov.nhtsa.mmucc.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import gov.nhtsa.mmucc.auth.config.TestFirebaseConfig;
import gov.nhtsa.mmucc.auth.dto.LoginRequest;
import gov.nhtsa.mmucc.auth.dto.TokenResponse;
import gov.nhtsa.mmucc.auth.entity.AppUser;
import gov.nhtsa.mmucc.auth.firebase.FirebaseAuthGateway;
import gov.nhtsa.mmucc.auth.firebase.FirebaseTokenClaims;
import gov.nhtsa.mmucc.auth.repository.AppUserRepository;
import gov.nhtsa.mmucc.auth.repository.CrashAuditLogRepository;
import gov.nhtsa.mmucc.common.audit.AuditFields;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        classes = {AuthServiceApplication.class}
)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
@Import(TestFirebaseConfig.class)
class AuthLoginIntegrationTest {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("mmucc_test")
            .withUsername("mmucc")
            .withPassword("mmucc_test");

    @DynamicPropertySource
    static void configureDataSource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }

    @Autowired MockMvc mockMvc;
    @Autowired ObjectMapper objectMapper;
    @Autowired AppUserRepository userRepository;
    @Autowired CrashAuditLogRepository auditLogRepository;

    @MockBean FirebaseAuthGateway firebaseAuthGateway;

    @Value("${mmucc.jwt.secret}")
    String jwtSecret;

    private static final String TEST_FIREBASE_UID = "uid-test-officer-001";
    private static final String TEST_EMAIL = "officer@state.gov";

    @BeforeEach
    void setUp() {
        auditLogRepository.deleteAll();
        userRepository.deleteAll();

        // Stub Firebase gateway for any token string
        when(firebaseAuthGateway.verifyIdToken(anyString()))
                .thenReturn(new FirebaseTokenClaims(TEST_FIREBASE_UID, TEST_EMAIL,
                        "Test Officer", true));
    }

    @Test
    void loginWithValidFirebaseToken_shouldReturn200AndAccessToken() throws Exception {
        insertActiveUser(TEST_FIREBASE_UID, "officer001", TEST_EMAIL, "DATA_ENTRY");

        LoginRequest request = new LoginRequest("any-mock-firebase-token");

        MvcResult result = mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.expiresIn").value(900))
                .andExpect(jsonPath("$.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.user.roleCode").value("DATA_ENTRY"))
                .andExpect(jsonPath("$.user.email").value(TEST_EMAIL))
                .andReturn();

        // Verify HttpOnly refresh cookie is set
        String setCookie = result.getResponse().getHeader("Set-Cookie");
        assertThat(setCookie).contains("mmucc-refresh-token");
        assertThat(setCookie).contains("HttpOnly");
        assertThat(setCookie).contains("Path=/auth/refresh");

        // Verify JWT claims
        TokenResponse tokenResponse = objectMapper.readValue(
                result.getResponse().getContentAsString(), TokenResponse.class);
        Claims claims = parseJwtClaims(tokenResponse.accessToken());
        assertThat(claims.get("role", String.class)).isEqualTo("DATA_ENTRY");
        assertThat(claims.getIssuer()).isEqualTo("mmucc-auth-service");

        // Verify audit log entry
        var logs = auditLogRepository.findAll();
        assertThat(logs).hasSize(1);
        assertThat(logs.get(0).getActionCode()).isEqualTo("LOGIN");
        assertThat(logs.get(0).getUsername()).isEqualTo("officer001");
    }

    @Test
    void loginWithLockedAccount_shouldReturn403() throws Exception {
        AppUser user = insertActiveUser(TEST_FIREBASE_UID, "locked_user", TEST_EMAIL, "VIEWER");
        user.setAccountLocked(true);
        userRepository.save(user);

        LoginRequest request = new LoginRequest("any-mock-firebase-token");

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isForbidden());
    }

    @Test
    void loginWithDisabledAccount_shouldReturn403() throws Exception {
        AppUser user = insertActiveUser(TEST_FIREBASE_UID, "disabled_user", TEST_EMAIL, "VIEWER");
        user.setActive(false);
        userRepository.save(user);

        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new LoginRequest("token"))))
                .andExpect(status().isForbidden());
    }

    @Test
    void loginMissingToken_shouldReturn400() throws Exception {
        mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"firebaseIdToken\": \"\"}"))
                .andExpect(status().isBadRequest());
    }

    @Test
    void refreshToken_shouldRotateTokenAndReturnNewAccessToken() throws Exception {
        insertActiveUser(TEST_FIREBASE_UID, "officer001", TEST_EMAIL, "DATA_ENTRY");

        // Login to get initial tokens
        MvcResult loginResult = mockMvc.perform(post("/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(new LoginRequest("token"))))
                .andExpect(status().isOk())
                .andReturn();

        String loginCookie = loginResult.getResponse().getHeader("Set-Cookie");
        assertThat(loginCookie).isNotNull();
        String rawRefreshToken = extractCookieValue(loginCookie, "mmucc-refresh-token");

        // Refresh — should succeed and return a new access token
        MvcResult refreshResult = mockMvc.perform(post("/auth/refresh")
                        .cookie(new jakarta.servlet.http.Cookie("mmucc-refresh-token", rawRefreshToken)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andReturn();

        // Verify old refresh token is no longer valid (rotation happened)
        mockMvc.perform(post("/auth/refresh")
                        .cookie(new jakarta.servlet.http.Cookie("mmucc-refresh-token", rawRefreshToken)))
                .andExpect(status().isUnauthorized());
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private AppUser insertActiveUser(String firebaseUid, String username,
                                     String email, String role) {
        AppUser user = new AppUser();
        user.setFirebaseUid(firebaseUid);
        user.setUsername(username);
        user.setEmail(email);
        user.setRoleCode(role);
        user.setActive(true);
        user.setAccountLocked(false);
        user.setFailedLoginCount(0);

        AuditFields audit = new AuditFields();
        audit.setCreatedBy("test-setup");
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
        user.setAudit(audit);

        return userRepository.save(user);
    }

    private Claims parseJwtClaims(String token) {
        return Jwts.parser()
                .verifyWith(Keys.hmacShaKeyFor(Decoders.BASE64.decode(jwtSecret)))
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    private String extractCookieValue(String setCookieHeader, String cookieName) {
        // Format: cookieName=value; Path=...; HttpOnly; ...
        return java.util.Arrays.stream(setCookieHeader.split(";"))
                .map(String::trim)
                .filter(part -> part.startsWith(cookieName + "="))
                .map(part -> part.substring(cookieName.length() + 1))
                .findFirst()
                .orElseThrow(() -> new AssertionError("Cookie not found: " + cookieName));
    }
}
