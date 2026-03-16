package gov.nhtsa.mmucc.crash;

import com.fasterxml.jackson.databind.ObjectMapper;
import gov.nhtsa.mmucc.common.security.JwtUtils;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.repository.CrashAuditLogRepository;
import gov.nhtsa.mmucc.crash.repository.CrashRepository;
import gov.nhtsa.mmucc.crash.repository.PersonRepository;
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
class PersonIntegrationTest {

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
    @Autowired PersonRepository personRepository;
    @Autowired CrashAuditLogRepository auditLogRepository;
    @Autowired JwtUtils jwtUtils;

    @Value("${mmucc.jwt.secret}")
    String jwtSecret;

    private String adminToken;
    private String dataEntryToken;
    private String viewerToken;

    @BeforeEach
    void setUp() {
        auditLogRepository.deleteAll();
        personRepository.deleteAll();
        vehicleRepository.deleteAll();
        crashRepository.deleteAll();

        adminToken     = buildJwt(1L, "ADMIN");
        dataEntryToken = buildJwt(2L, "DATA_ENTRY");
        viewerToken    = buildJwt(3L, "VIEWER");
    }

    // -----------------------------------------------------------------------
    // POST /crashes/{crashId}/vehicles/{vehicleId}/persons
    // -----------------------------------------------------------------------

    @Test
    void createPerson_asDataEntry_shouldReturn201() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-001");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        PersonRequest request = minimalPersonRequest();

        mockMvc.perform(post("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.personId").isNumber())
                .andExpect(jsonPath("$.vehicleId").value(vehicleId))
                .andExpect(jsonPath("$.crashId").value(crashId));
    }

    @Test
    void createPerson_asViewer_shouldReturn403() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-403");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        mockMvc.perform(post("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons")
                        .header("Authorization", "Bearer " + viewerToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(minimalPersonRequest())))
                .andExpect(status().isForbidden());
    }

    @Test
    void getPerson_byId_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-GET");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId)
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.personId").value(personId));
    }

    @Test
    void listPersons_forVehicle_shouldReturnAll() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-LIST");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        createPersonViaApi(crashId, vehicleId);
        createPersonViaApi(crashId, vehicleId);

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2));
    }

    @Test
    void updatePerson_shouldReturn200WithUpdatedFields() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-UPD");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        PersonRequest update = new PersonRequest(
                "John Updated", // personName
                null, null, null, 30, // dobYear, dobMonth, dobDay, ageYears
                2, // sexCode
                1, null, // personTypeCode, incidentResponderCode
                5, // injuryStatusCode
                null, null, null, // vehicleUnitNumber, seatingRowCode, seatingSeatCode
                null, null, // restraintCode, restraintImproperFlg
                List.of(), // airbags
                null, // ejectionCode
                null, null, // dlJurisdictionType, dlJurisdictionCode
                null, null, null, null, // dlNumber, dlClassCode, dlIsCdlFlg, dlEndorsementCode
                null, // speedingCode
                List.of(), // driverActions
                null, null, // violationCode1, violationCode2
                List.of(), null, // dlRestrictions, dlAlcoholInterlockFlg
                null, null, // dlStatusTypeCode, dlStatusCode
                null, null, // distractedActionCode, distractedSourceCode
                null, null, // conditionCode1, conditionCode2
                null, // leSuspectsAlcohol
                null, null, null, // alcoholTestStatusCode, alcoholTestTypeCode, alcoholBacResult
                null, // leSuspectsDrug
                null, null, // drugTestStatusCode, drugTestTypeCode
                List.of(), // drugTestResults
                null, null, null, null, // transportSourceCode, emsAgencyId, emsRunNumber, medicalFacility
                null, null, null // injuryAreaCode, injuryDiagnosis, injurySeverityCode
        );

        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId)
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(update)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.personName").value("John Updated"))
                .andExpect(jsonPath("$.ageYears").value(30));
    }

    @Test
    void deletePerson_asAdmin_shouldReturn204ThenNotFound() throws Exception {
        Long crashId = createCrashViaApi("CR-PRS-DEL");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        mockMvc.perform(delete("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId)
                        .header("Authorization", "Bearer " + adminToken))
                .andExpect(status().isNoContent());

        assertThat(personRepository.findById(personId)).isEmpty();
    }

    // -----------------------------------------------------------------------
    // Fatal Section
    // -----------------------------------------------------------------------

    @Test
    void upsertFatalSection_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-FSC-001");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        FatalSectionRequest request = new FatalSectionRequest(9, 1, "000", 1, 1);

        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/fatal")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.personId").value(personId))
                .andExpect(jsonPath("$.avoidanceManeuverCode").value(9));
    }

    @Test
    void getFatalSection_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-FSC-GET");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        FatalSectionRequest request = new FatalSectionRequest(5, null, null, null, null);
        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/fatal")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/fatal")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.avoidanceManeuverCode").value(5));
    }

    // -----------------------------------------------------------------------
    // Non-Motorist Section
    // -----------------------------------------------------------------------

    @Test
    void upsertNonMotorist_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-NMT-001");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        NonMotoristRequest request = new NonMotoristRequest(
                1, 2, null, 0, null, 3, 12,
                List.of(new ChildCodeDto(1, 1))
        );

        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/non-motorist")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.personId").value(personId))
                .andExpect(jsonPath("$.strikingVehicleUnit").value(1))
                .andExpect(jsonPath("$.safetyEquipment.length()").value(1));
    }

    @Test
    void getNonMotorist_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-NMT-GET");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);
        Long personId = createPersonViaApi(crashId, vehicleId);

        NonMotoristRequest request = new NonMotoristRequest(
                2, null, null, null, null, null, null, List.of()
        );
        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/non-motorist")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons/" + personId + "/non-motorist")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.strikingVehicleUnit").value(2));
    }

    // -----------------------------------------------------------------------
    // Large Vehicle Section
    // -----------------------------------------------------------------------

    @Test
    void upsertLargeVehicle_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-LVH-001");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        LargeVehicleRequest request = new LargeVehicleRequest(
                7, 1,
                null, null, null,
                null, null, null,
                null, null, null,
                null, null, null,
                null, null, null,
                1, "US", "1234567",
                "ACME Trucking", null, null, "Springfield", "IL", "62701", "US",
                1, 8, 1, 12,
                "1203", "3", 1,
                3, 2, null, null,
                List.of(new ChildCodeDto(1, 2))
        );

        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/large-vehicle")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vehicleId").value(vehicleId))
                .andExpect(jsonPath("$.cmvLicenseStatusCode").value(7))
                .andExpect(jsonPath("$.specialSizing.length()").value(1));
    }

    @Test
    void getLargeVehicle_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-LVH-GET");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        LargeVehicleRequest request = new LargeVehicleRequest(
                6, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null, null,
                List.of()
        );
        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/large-vehicle")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/large-vehicle")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.cmvLicenseStatusCode").value(6));
    }

    // -----------------------------------------------------------------------
    // Vehicle Automation Section
    // -----------------------------------------------------------------------

    @Test
    void upsertAutomation_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-VAT-001");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        VehicleAutomationRequest request = new VehicleAutomationRequest(
                2,
                List.of(new ChildCodeDto(1, 2), new ChildCodeDto(2, 3)),
                List.of(new ChildCodeDto(1, 2))
        );

        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/automation")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.vehicleId").value(vehicleId))
                .andExpect(jsonPath("$.automationPresentCode").value(2))
                .andExpect(jsonPath("$.levelsInVehicle.length()").value(2))
                .andExpect(jsonPath("$.levelsEngaged.length()").value(1));
    }

    @Test
    void getAutomation_shouldReturn200() throws Exception {
        Long crashId = createCrashViaApi("CR-VAT-GET");
        Long vehicleId = addVehicleViaApi(crashId, "VIN001", 1);

        VehicleAutomationRequest request = new VehicleAutomationRequest(1, List.of(), List.of());
        mockMvc.perform(put("/crashes/" + crashId + "/vehicles/" + vehicleId + "/automation")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk());

        mockMvc.perform(get("/crashes/" + crashId + "/vehicles/" + vehicleId + "/automation")
                        .header("Authorization", "Bearer " + viewerToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.automationPresentCode").value(1));
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    private Long createCrashViaApi(String identifier) throws Exception {
        CrashRequest request = new CrashRequest(
                identifier, null, null, LocalDate.of(2024, 1, 15), null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null, null
        );
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

    private Long addVehicleViaApi(Long crashId, String vin, int unitNumber) throws Exception {
        VehicleRequest req = new VehicleRequest(
                vin, 1, unitNumber, "VA", 2020, "ABC123", "Toyota", 2020, "Camry",
                null, null, null, null, null, null, null, null,
                null, null, null, null, null, null, null, null, null,
                null, null, null, null, null, null,
                null, null,
                List.of(), List.of(), List.of()
        );
        MvcResult result = mockMvc.perform(post("/crashes/" + crashId + "/vehicles")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isCreated())
                .andReturn();
        VehicleResponse response = objectMapper.readValue(
                result.getResponse().getContentAsString(), VehicleResponse.class);
        return response.vehicleId();
    }

    private Long createPersonViaApi(Long crashId, Long vehicleId) throws Exception {
        MvcResult result = mockMvc.perform(post("/crashes/" + crashId + "/vehicles/" + vehicleId + "/persons")
                        .header("Authorization", "Bearer " + dataEntryToken)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(minimalPersonRequest())))
                .andExpect(status().isCreated())
                .andReturn();
        PersonResponse response = objectMapper.readValue(
                result.getResponse().getContentAsString(), PersonResponse.class);
        return response.personId();
    }

    private PersonRequest minimalPersonRequest() {
        return new PersonRequest(
                "Jane Doe", // personName
                null, null, null, 25, // dobYear, dobMonth, dobDay, ageYears
                1, // sexCode
                1, null, // personTypeCode, incidentResponderCode
                4, // injuryStatusCode
                null, null, null, // vehicleUnitNumber, seatingRowCode, seatingSeatCode
                null, null, // restraintCode, restraintImproperFlg
                List.of(), // airbags
                null, // ejectionCode
                null, null, // dlJurisdictionType, dlJurisdictionCode
                null, null, null, null, // dlNumber, dlClassCode, dlIsCdlFlg, dlEndorsementCode
                null, // speedingCode
                List.of(), // driverActions
                null, null, // violationCode1, violationCode2
                List.of(), null, // dlRestrictions, dlAlcoholInterlockFlg
                null, null, // dlStatusTypeCode, dlStatusCode
                null, null, // distractedActionCode, distractedSourceCode
                null, null, // conditionCode1, conditionCode2
                null, // leSuspectsAlcohol
                null, null, null, // alcoholTestStatusCode, alcoholTestTypeCode, alcoholBacResult
                null, // leSuspectsDrug
                null, null, // drugTestStatusCode, drugTestTypeCode
                List.of(), // drugTestResults
                null, null, null, null, // transportSourceCode, emsAgencyId, emsRunNumber, medicalFacility
                null, null, null // injuryAreaCode, injuryDiagnosis, injurySeverityCode
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
