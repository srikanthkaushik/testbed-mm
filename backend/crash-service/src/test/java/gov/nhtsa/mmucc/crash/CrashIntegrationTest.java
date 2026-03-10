package gov.nhtsa.mmucc.crash;

import com.fasterxml.jackson.databind.ObjectMapper;
import gov.nhtsa.mmucc.common.security.JwtUtils;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.repository.CrashAuditLogRepository;
import gov.nhtsa.mmucc.crash.repository.CrashRepository;
import gov.nhtsa.mmucc.crash.repository.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.LocalDate;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Testcontainers
class CrashIntegrationTest {

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
    @Autowired CrashRepository crashRepository;
    @Autowired VehicleRepository vehicleRepository;
    @Autowired CrashAuditLogRepository auditLogRepository;

    @Autowired JwtUtils jwtUtils;

    @Value("${mmucc.jwt.secret}")
    String jwtSecret;

    // Tokens for different roles
    private String adminToken;
    private String dataEntryToken;
    private String viewerToken;

    @BeforeEach
    void setUp() {
        auditLogRepository.deleteAll();
        vehicleRepository.deleteAll();
        crashRepository.deleteAll();

        adminToken     = buildJwt(1L, "ADMIN");
        dataEntryToken = buildJwt(2L, "DATA_ENTRY");
        viewerToken    = buildJwt(3L, "VIEWER");
    }

    // -----------------------------------------------------------------------
    // POST /crashes
    // -----------------------------------------------------------------------

    @Test
    void createCrash_asDataEntry_shouldReturn201WithId() throws Exception {
        CrashRequest request = minimalCrashRequest("CR-2024-001");

        MvcResult result = mockMvc.perform(post("/crashes")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.crashId").isNumber())
                .andExpect(jsonPath("$.crashIdentifier").value("CR-2024-001"))
                .andReturn();

        CrashDetailResponse response = objectMapper.readValue(
                result.getResponse().getContentAsString(), CrashDetailResponse.class);
        assertThat(response.crashId()).isPositive();
        assertThat(response.createdBy()).isEqualTo("dataentry_user");
    }

    @Test
    void createCrash_withWeatherConditions_shouldPersistChildren() throws Exception {
        CrashRequest request = new CrashRequest(
                "CR-2024-002", 1, null, LocalDate.of(2024, 6, 15), null,
                "001", "Adams", null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, 2, null, null,
                null, null, null, null, null, null,
                List.of(new ChildCodeDto(1, 1), new ChildCodeDto(2, 3)),  // 2 weather conditions
                null, null
        );

        mockMvc.perform(post("/crashes")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.weatherConditions.length()").value(2))
                .andExpect(jsonPath("$.weatherConditions[0].sequenceNum").value(1))
                .andExpect(jsonPath("$.weatherConditions[0].code").value(1));
    }

    @Test
    void createCrash_asViewer_shouldReturn403() throws Exception {
        mockMvc.perform(post("/crashes")
                        .header("Authorization", "Bearer " + viewerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(minimalCrashRequest("CR-FAIL"))))
                .andExpect(status().isForbidden());
    }

    @Test
    void createCrash_unauthenticated_shouldReturn401() throws Exception {
        mockMvc.perform(post("/crashes")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(minimalCrashRequest("CR-FAIL"))))
                .andExpect(status().isUnauthorized());
    }

    // -----------------------------------------------------------------------
    // GET /crashes/{id}
    // -----------------------------------------------------------------------

    @Test
    void getCrash_existingId_shouldReturn200() throws Exception {
        Long id = createCrashViaApi("CR-READ-001");

        mockMvc.perform(get("/crashes/" + id)
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.crashId").value(id))
                .andExpect(jsonPath("$.crashIdentifier").value("CR-READ-001"));
    }

    @Test
    void getCrash_nonExistentId_shouldReturn404() throws Exception {
        mockMvc.perform(get("/crashes/99999")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isNotFound());
    }

    // -----------------------------------------------------------------------
    // GET /crashes (list with filters)
    // -----------------------------------------------------------------------

    @Test
    void listCrashes_noFilters_shouldReturnPagedResults() throws Exception {
        createCrashViaApi("CR-LIST-001");
        createCrashViaApi("CR-LIST-002");

        mockMvc.perform(get("/crashes?page=0&size=10")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content.length()").value(2))
                .andExpect(jsonPath("$.totalElements").value(2));
    }

    // -----------------------------------------------------------------------
    // PUT /crashes/{id}
    // -----------------------------------------------------------------------

    @Test
    void updateCrash_asDataEntry_shouldReturn200WithUpdatedFields() throws Exception {
        Long id = createCrashViaApi("CR-UPDATE-ORIG");

        CrashRequest update = minimalCrashRequest("CR-UPDATE-NEW");

        mockMvc.perform(put("/crashes/" + id)
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(update)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.crashIdentifier").value("CR-UPDATE-NEW"));

        // Verify audit log captured before/after
        var logs = auditLogRepository.findAll();
        // CREATE + UPDATE = 2 entries
        assertThat(logs).hasSize(2);
        assertThat(logs.stream()
                .filter(l -> "UPDATE".equals(l.getActionCode()))
                .findFirst()).isPresent();
    }

    // -----------------------------------------------------------------------
    // DELETE /crashes/{id}
    // -----------------------------------------------------------------------

    @Test
    void deleteCrash_asAdmin_shouldReturn204AndRemoveRecord() throws Exception {
        Long id = createCrashViaApi("CR-DELETE-001");

        mockMvc.perform(delete("/crashes/" + id)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isNoContent());

        assertThat(crashRepository.findById(id)).isEmpty();
    }

    @Test
    void deleteCrash_asDataEntry_shouldReturn403() throws Exception {
        Long id = createCrashViaApi("CR-NO-DELETE");

        mockMvc.perform(delete("/crashes/" + id)
                        .header("Authorization", "Bearer " + dataEntryToken))
                .andExpect(status().isForbidden());
    }

    // -----------------------------------------------------------------------
    // POST /crashes/{id}/vehicles
    // -----------------------------------------------------------------------

    @Test
    void addVehicle_toCrash_shouldReturn201() throws Exception {
        Long crashId = createCrashViaApi("CR-VEH-001");

        VehicleRequest vehicleRequest = new VehicleRequest(
                "1HGBH41JXMN109186", 1, 1,
                "VA", 2022, "ABC1234", "Honda", 2022, "Civic",
                null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null, null
        );

        mockMvc.perform(post("/crashes/" + crashId + "/vehicles")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(vehicleRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.vehicleId").isNumber())
                .andExpect(jsonPath("$.vin").value("1HGBH41JXMN109186"))
                .andExpect(jsonPath("$.crashId").value(crashId));
    }

    @Test
    void listVehicles_forCrash_shouldReturnAllVehicles() throws Exception {
        Long crashId = createCrashViaApi("CR-VEH-LIST");
        addVehicleViaApi(crashId, "VIN001", 1);
        addVehicleViaApi(crashId, "VIN002", 2);

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2));
    }

    // -----------------------------------------------------------------------
    // PUT /crashes/{crashId}/roadway
    // -----------------------------------------------------------------------

    @Test
    void upsertRoadway_forCrash_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-RWY-001");

        // RoadwayRequest: 28 fields (bridgeStructureId..enteringVehiclesAadt)
        RoadwayRequest roadwayRequest = new RoadwayRequest(
                null, null, null, null, null, null,  // 1-6: bridge..gradePercent
                1, 1,                                // 7: nationalHwySysCode, 8: functionalClassCode
                null, null, null, null,              // 9-12
                null, null, null, null,              // 13-16
                null, null, null, null,              // 17-20
                null, null, null, null,              // 21-24
                null, null, null, null               // 25-28
        );

        mockMvc.perform(put("/crashes/" + crashId + "/roadway")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(roadwayRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.crashId").value(crashId));
    }

    @Test
    void upsertRoadway_calledTwice_shouldUpdateNotDuplicate() throws Exception {
        Long crashId = createCrashViaApi("CR-RWY-UPSERT");

        RoadwayRequest first = minimalRoadwayRequest(1);
        RoadwayRequest second = minimalRoadwayRequest(2);

        mockMvc.perform(put("/crashes/" + crashId + "/roadway")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(first)))
                .andExpect(status().isOk());

        mockMvc.perform(put("/crashes/" + crashId + "/roadway")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(second)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nationalHwySysCode").value(2));
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private Long createCrashViaApi(String identifier) throws Exception {
        CrashRequest request = minimalCrashRequest(identifier);
        MvcResult result = mockMvc.perform(post("/crashes")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andReturn();
        CrashDetailResponse response = objectMapper.readValue(
                result.getResponse().getContentAsString(), CrashDetailResponse.class);
        return response.crashId();
    }

    private void addVehicleViaApi(Long crashId, String vin, int unitNumber) throws Exception {
        VehicleRequest req = new VehicleRequest(
                vin, 1, unitNumber, "VA", 2020, "ABC123", "Toyota", 2020, "Camry",
                null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null, null
        );
        mockMvc.perform(post("/crashes/" + crashId + "/vehicles")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated());
    }

    private CrashRequest minimalCrashRequest(String identifier) {
        return new CrashRequest(
                identifier, null, null, LocalDate.of(2024, 1, 15), null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null, null
        );
    }

    private RoadwayRequest minimalRoadwayRequest(int nationalHwySysCode) {
        // RoadwayRequest: 28 fields (bridgeStructureId..enteringVehiclesAadt)
        return new RoadwayRequest(
                null, null, null, null, null, null,  // 1-6: bridge..gradePercent
                nationalHwySysCode,                  // 7: nationalHwySysCode
                null, null, null, null, null,        // 8-12
                null, null, null, null, null,        // 13-17
                null, null, null, null, null,        // 18-22
                null, null, null, null, null, null   // 23-28
        );
    }

    private String buildJwt(Long userId, String role) {
        String username = switch (role) {
            case "ADMIN"      -> "admin_user";
            case "DATA_ENTRY" -> "dataentry_user";
            default           -> "viewer_user";
        };
        return jwtUtils.generateAccessToken(
                userId, "firebase-uid-" + userId, username,
                username + "@test.gov", role, "NHTSA");
    }
}
