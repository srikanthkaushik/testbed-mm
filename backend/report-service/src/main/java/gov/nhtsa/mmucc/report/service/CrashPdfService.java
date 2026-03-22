package gov.nhtsa.mmucc.report.service;

import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import gov.nhtsa.mmucc.report.util.MmuccLookup;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@Transactional(readOnly = true)
public class CrashPdfService {

    private final JdbcTemplate jdbc;
    private final TemplateEngine templateEngine;

    public CrashPdfService(JdbcTemplate jdbc, TemplateEngine templateEngine) {
        this.jdbc = jdbc;
        this.templateEngine = templateEngine;
    }

    // ── Public API ─────────────────────────────────────────────────────────

    public byte[] generatePdf(Long crashId) throws IOException {
        Map<String, Object> model = buildModel(crashId);

        Context ctx = new Context();
        ctx.setVariables(model);

        String html = templateEngine.process("crash-report", ctx);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfRendererBuilder builder = new PdfRendererBuilder();
        builder.useFastMode();
        builder.withHtmlContent(html, null);
        builder.toStream(baos);
        builder.run();

        return baos.toByteArray();
    }

    // ── Model builder ──────────────────────────────────────────────────────

    private Map<String, Object> buildModel(Long crashId) {

        // 1. Crash header
        Map<String, Object> crash;
        try {
            crash = jdbc.queryForMap(
                "SELECT * FROM CRASH_TBL WHERE CRS_CRASH_ID = ?", crashId);
        } catch (EmptyResultDataAccessException e) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                "Crash not found: " + crashId);
        }

        // 2. Crash child tables
        List<Map<String, Object>> weatherRows =
            jdbc.queryForList(
                "SELECT CWC_WEATHER_CODE FROM CRASH_WEATHER_CONDITION_TBL WHERE CWC_CRASH_ID = ?",
                crashId);
        List<Map<String, Object>> surfaceRows =
            jdbc.queryForList(
                "SELECT CSC_SURFACE_CODE FROM CRASH_SURFACE_CONDITION_TBL WHERE CSC_CRASH_ID = ?",
                crashId);
        List<Map<String, Object>> contribRows =
            jdbc.queryForList(
                "SELECT CCR_CIRCUMSTANCE_CODE FROM CRASH_CONTRIBUTING_ROADWAY_TBL WHERE CCR_CRASH_ID = ?",
                crashId);

        // 3. Roadway
        Map<String, Object> roadway = null;
        try {
            roadway = jdbc.queryForMap(
                "SELECT * FROM ROADWAY_TBL WHERE RWY_CRASH_ID = ?", crashId);
        } catch (EmptyResultDataAccessException ignored) {}

        // 4. Vehicles
        List<Map<String, Object>> vehicleRows =
            jdbc.queryForList(
                "SELECT * FROM VEHICLE_TBL WHERE VEH_CRASH_ID = ? ORDER BY VEH_UNIT_NUMBER, VEH_VEHICLE_ID",
                crashId);

        List<Map<String, Object>> vehicles = new ArrayList<>();
        for (Map<String, Object> veh : vehicleRows) {
            Long vehicleId = toLong(veh.get("VEH_VEHICLE_ID"));

            List<Map<String, Object>> trafficControls =
                jdbc.queryForList(
                    "SELECT VTC_SEQUENCE_NUM, VTC_TCD_TYPE_CODE FROM VEHICLE_TRAFFIC_CONTROL_TBL WHERE VTC_VEHICLE_ID = ? ORDER BY VTC_SEQUENCE_NUM",
                    vehicleId);
            List<Map<String, Object>> damageAreas =
                jdbc.queryForList(
                    "SELECT VDA_AREA_CODE FROM VEHICLE_DAMAGE_AREA_TBL WHERE VDA_VEHICLE_ID = ? ORDER BY VDA_SEQUENCE_NUM",
                    vehicleId);
            List<Map<String, Object>> seqEvents =
                jdbc.queryForList(
                    "SELECT VSE_EVENT_CODE FROM VEHICLE_SEQUENCE_EVENT_TBL WHERE VSE_VEHICLE_ID = ? ORDER BY VSE_SEQUENCE_NUM",
                    vehicleId);

            // Large vehicle
            Map<String, Object> largeVehicle = null;
            try {
                largeVehicle = jdbc.queryForMap(
                    "SELECT * FROM LARGE_VEHICLE_TBL WHERE LVH_VEHICLE_ID = ?", vehicleId);
                List<Map<String, Object>> specialSizing =
                    jdbc.queryForList(
                        "SELECT LSS_SPECIAL_SIZING_CODE FROM LV_SPECIAL_SIZING_TBL WHERE LSS_VEHICLE_ID = ?",
                        vehicleId);
                largeVehicle.put("_specialSizing", specialSizing);
            } catch (EmptyResultDataAccessException ignored) {}

            // Automation
            Map<String, Object> automation = null;
            try {
                automation = jdbc.queryForMap(
                    "SELECT * FROM VEHICLE_AUTOMATION_TBL WHERE VAT_VEHICLE_ID = ?", vehicleId);
                List<Map<String, Object>> levelsInVehicle =
                    jdbc.queryForList(
                        "SELECT VAI_AUTOMATION_LEVEL_CODE FROM VEHICLE_AUTOMATION_LEVEL_IN_VEHICLE_TBL WHERE VAI_VEHICLE_ID = ?",
                        vehicleId);
                List<Map<String, Object>> levelsEngaged =
                    jdbc.queryForList(
                        "SELECT VAE_AUTOMATION_LEVEL_CODE FROM VEHICLE_AUTOMATION_LEVEL_ENGAGED_TBL WHERE VAE_VEHICLE_ID = ?",
                        vehicleId);
                automation.put("_levelsInVehicle", levelsInVehicle);
                automation.put("_levelsEngaged", levelsEngaged);
            } catch (EmptyResultDataAccessException ignored) {}

            Map<String, Object> vehModel = new HashMap<>(veh);
            vehModel.put("_trafficControls", trafficControls);
            vehModel.put("_damageAreas", damageAreas);
            vehModel.put("_seqEvents", seqEvents);
            vehModel.put("_largeVehicle", largeVehicle);
            vehModel.put("_automation", automation);

            // Persons for this vehicle
            List<Map<String, Object>> personRows =
                jdbc.queryForList(
                    "SELECT * FROM PERSON_TBL WHERE PRS_VEHICLE_ID = ? ORDER BY PRS_PERSON_ID",
                    vehicleId);
            vehModel.put("_persons", buildPersons(personRows));

            vehicles.add(vehModel);
        }

        // 5. Build lookup labels for display
        Map<String, Object> model = new HashMap<>();
        model.put("crash", crash);
        model.put("weatherLabels",  codeListLabels(weatherRows,  "CWC_WEATHER_CODE",      MmuccLookup.WEATHER));
        model.put("surfaceLabels",  codeListLabels(surfaceRows,  "CSC_SURFACE_CODE",       MmuccLookup.SURFACE_CONDITION));
        model.put("contribLabels",  codeListLabels(contribRows,  "CCR_CIRCUMSTANCE_CODE",  MmuccLookup.CONTRIBUTING_CIRC));
        model.put("roadway", roadway);
        model.put("vehicles", vehicles);
        model.put("L", MmuccLookup.class); // expose static helper for inline calls via Thymeleaf

        // Pre-compute crash-level labels (avoids complex inline Thymeleaf calls)
        model.put("crashSeverityLabel",    label(crash, "CRS_CRASH_SEVERITY_CODE",            MmuccLookup.CRASH_SEVERITY));
        model.put("crashTypeLabel",        label(crash, "CRS_CRASH_TYPE_CODE",                MmuccLookup.CRASH_TYPE));
        model.put("harmfulEventLabel",     label(crash, "CRS_FIRST_HARMFUL_EVENT_CODE",       MmuccLookup.HARMFUL_EVENT));
        model.put("mannerCollisionLabel",  label(crash, "CRS_MANNER_COLLISION_CODE",          MmuccLookup.MANNER_COLLISION));
        model.put("sourceOfInfoLabel",     label(crash, "CRS_SOURCE_OF_INFO_CODE",            MmuccLookup.SOURCE_OF_INFO));
        model.put("lightConditionLabel",   label(crash, "CRS_LIGHT_CONDITION_CODE",           MmuccLookup.LIGHT_CONDITION));
        model.put("junctionLocationLabel", label(crash, "CRS_JUNCTION_LOCATION_CODE",         MmuccLookup.JUNCTION_LOCATION));
        model.put("intersectionGeoLabel",  label(crash, "CRS_INTERSECTION_GEOMETRY_CODE",     MmuccLookup.INTERSECTION_GEOMETRY));
        model.put("intersectionCtlLabel",  label(crash, "CRS_INTERSECTION_TRAFFIC_CTL_CODE",  MmuccLookup.INTERSECTION_TRAFFIC_CTL));
        model.put("schoolBusLabel",        label(crash, "CRS_SCHOOL_BUS_RELATED_CODE",        MmuccLookup.SCHOOL_BUS));
        model.put("workZoneLabel",         label(crash, "CRS_WORK_ZONE_RELATED_CODE",         MmuccLookup.WORK_ZONE));
        model.put("workZoneLocLabel",      label(crash, "CRS_WORK_ZONE_LOCATION_CODE",        MmuccLookup.WORK_ZONE_LOCATION));
        model.put("workZoneTypeLabel",     label(crash, "CRS_WORK_ZONE_TYPE_CODE",            MmuccLookup.WORK_ZONE_TYPE));
        model.put("workZoneWorkersLabel",  label(crash, "CRS_WORK_ZONE_WORKERS_CODE",         MmuccLookup.WORK_ZONE_WORKERS));
        model.put("workZoneLawEnfLabel",   label(crash, "CRS_WORK_ZONE_LAW_ENF_CODE",         MmuccLookup.WORK_ZONE_LAW_ENF));
        model.put("alcoholInvLabel",       label(crash, "CRS_ALCOHOL_INVOLVEMENT_CODE",       MmuccLookup.ALCOHOL_INVOLVEMENT));
        model.put("drugInvLabel",          label(crash, "CRS_DRUG_INVOLVEMENT_CODE",          MmuccLookup.DRUG_INVOLVEMENT));
        model.put("dayOfWeekLabel",        label(crash, "CRS_DAY_OF_WEEK_CODE",              MmuccLookup.DAY_OF_WEEK));
        model.put("routeTypeLabel",        label(crash, "CRS_ROUTE_TYPE_CODE",               MmuccLookup.ROUTE_TYPE));
        model.put("routeDirLabel",         label(crash, "CRS_ROUTE_DIRECTION_CODE",           MmuccLookup.ROUTE_DIRECTION));
        model.put("refPointDirLabel",      label(crash, "CRS_REF_POINT_DIRECTION_CODE",       MmuccLookup.REF_POINT_DIRECTION));
        model.put("locFirstHarmLabel",     label(crash, "CRS_LOC_FIRST_HARMFUL_EVENT_CODE",   MmuccLookup.LOC_FIRST_HARMFUL));

        // Roadway labels
        if (roadway != null) {
            model.put("nhsLabel",             label(roadway, "RWY_NATIONAL_HWY_SYS_CODE",      MmuccLookup.NHS));
            model.put("functionalClassLabel", label(roadway, "RWY_FUNCTIONAL_CLASS_CODE",      MmuccLookup.FUNCTIONAL_CLASS));
            model.put("accessControlLabel",   label(roadway, "RWY_ACCESS_CONTROL_CODE",        MmuccLookup.ACCESS_CONTROL));
            model.put("roadwayLightingLabel", label(roadway, "RWY_ROADWAY_LIGHTING_CODE",      MmuccLookup.ROADWAY_LIGHTING));
            model.put("edgelineLabel",        label(roadway, "RWY_PAVEMENT_EDGELINE_CODE",     MmuccLookup.PAVEMENT_MARKING));
            model.put("centerlineLabel",      label(roadway, "RWY_PAVEMENT_CENTERLINE_CODE",   MmuccLookup.PAVEMENT_MARKING));
            model.put("lanelineLabel",        label(roadway, "RWY_PAVEMENT_LANELINE_CODE",     MmuccLookup.PAVEMENT_MARKING));
            model.put("bicycleFacilLabel",    label(roadway, "RWY_BICYCLE_FACILITY_CODE",      MmuccLookup.BICYCLE_FACILITY));
            model.put("bicycleRouteLabel",    label(roadway, "RWY_BICYCLE_SIGNED_ROUTE_CODE",  MmuccLookup.BICYCLE_SIGNED_ROUTE));
        }

        // Vehicle labels list — parallel list matching vehicles
        List<Map<String, Object>> vehicleLabels = new ArrayList<>();
        for (Map<String, Object> veh : vehicles) {
            Map<String, Object> vl = new HashMap<>();
            vl.put("unitTypeLabel",       label(veh, "VEH_UNIT_TYPE_CODE",          MmuccLookup.UNIT_TYPE));
            vl.put("bodyTypeLabel",       label(veh, "VEH_BODY_TYPE_CODE",          MmuccLookup.BODY_TYPE));
            vl.put("vehicleSizeLabel",    label(veh, "VEH_VEHICLE_SIZE_CODE",        MmuccLookup.VEHICLE_SIZE));
            vl.put("hmPlacardLabel",      label(veh, "VEH_HM_PLACARD_FLG",          MmuccLookup.HM_PLACARD));
            vl.put("specialFuncLabel",    label(veh, "VEH_SPECIAL_FUNCTION_CODE",    MmuccLookup.SPECIAL_FUNCTION));
            vl.put("emergencyUseLabel",   label(veh, "VEH_EMERGENCY_USE_CODE",       MmuccLookup.EMERGENCY_USE));
            vl.put("dirTravelLabel",      label(veh, "VEH_DIRECTION_OF_TRAVEL_CODE", MmuccLookup.DIRECTION_OF_TRAVEL));
            vl.put("twTravelDirLabel",    label(veh, "VEH_TRAFFICWAY_TRAVEL_DIR_CODE",MmuccLookup.TRAFFICWAY_TRAVEL_DIR));
            vl.put("twDividedLabel",      label(veh, "VEH_TRAFFICWAY_DIVIDED_CODE",  MmuccLookup.TRAFFICWAY_DIVIDED));
            vl.put("twBarrierLabel",      label(veh, "VEH_TRAFFICWAY_BARRIER_CODE",  MmuccLookup.TRAFFICWAY_BARRIER));
            vl.put("twHovHotLabel",       label(veh, "VEH_TRAFFICWAY_HOV_HOT_CODE",  MmuccLookup.TRAFFICWAY_HOV_HOT));
            vl.put("hovCrashLabel",       label(veh, "VEH_TRAFFICWAY_HOV_CRASH_FLG", MmuccLookup.HOV_CRASH));
            vl.put("alignmentLabel",      label(veh, "VEH_ROADWAY_ALIGNMENT_CODE",   MmuccLookup.ROADWAY_ALIGNMENT));
            vl.put("gradeLabel",          label(veh, "VEH_ROADWAY_GRADE_CODE",       MmuccLookup.ROADWAY_GRADE));
            vl.put("maneuverLabel",       label(veh, "VEH_MANEUVER_CODE",            MmuccLookup.MANEUVER));
            vl.put("damageExtentLabel",   label(veh, "VEH_DAMAGE_EXTENT_CODE",       MmuccLookup.DAMAGE_EXTENT));
            vl.put("mostHarmLabel",       label(veh, "VEH_MOST_HARMFUL_EVENT_CODE",  MmuccLookup.HARMFUL_EVENT));
            vl.put("hitRunLabel",         label(veh, "VEH_HIT_AND_RUN_CODE",         MmuccLookup.HIT_AND_RUN));
            vl.put("towedLabel",          label(veh, "VEH_TOWED_CODE",               MmuccLookup.TOWED));
            vl.put("vehContribLabel",     label(veh, "VEH_CONTRIBUTING_CIRC_CODE",   MmuccLookup.CONTRIBUTING_CIRC));

            // Child list labels
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> tcList = (List<Map<String, Object>>) veh.get("_trafficControls");
            vl.put("trafficControlLabels", tcList == null ? "—" :
                tcList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("VTC_TCD_TYPE_CODE")), MmuccLookup.TRAFFIC_CONTROL))
                    .collect(Collectors.joining(", ")));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> daList = (List<Map<String, Object>>) veh.get("_damageAreas");
            vl.put("damageAreaLabels", daList == null ? "—" :
                daList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("VDA_AREA_CODE")), MmuccLookup.DAMAGE_AREA))
                    .collect(Collectors.joining(", ")));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> seList = (List<Map<String, Object>>) veh.get("_seqEvents");
            vl.put("seqEventLabels", seList == null ? "—" :
                seList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("VSE_EVENT_CODE")), MmuccLookup.SEQUENCE_EVENTS))
                    .collect(Collectors.joining(", ")));

            // Large vehicle labels
            @SuppressWarnings("unchecked")
            Map<String, Object> lv = (Map<String, Object>) veh.get("_largeVehicle");
            if (lv != null) {
                Map<String, Object> lvl = new HashMap<>();
                lvl.put("cmvLicStatusLabel",  label(lv, "LVH_CMV_LICENSE_STATUS_CODE", MmuccLookup.CMV_LICENSE_STATUS));
                lvl.put("cdlComplianceLabel", label(lv, "LVH_CDL_COMPLIANCE_CODE",     MmuccLookup.CDL_COMPLIANCE));
                lvl.put("carrierIdTypeLabel", label(lv, "LVH_CARRIER_ID_TYPE_CODE",    MmuccLookup.CARRIER_ID_TYPE));
                lvl.put("carrierTypeLabel",   label(lv, "LVH_CARRIER_TYPE_CODE",       MmuccLookup.CARRIER_TYPE));
                lvl.put("vehicleConfigLabel", label(lv, "LVH_VEHICLE_CONFIG_CODE",     MmuccLookup.VEHICLE_CONFIG));
                lvl.put("vehiclePermLabel",   label(lv, "LVH_VEHICLE_PERMITTED_CODE",  MmuccLookup.VEHICLE_PERMITTED));
                lvl.put("cargoBodyLabel",     label(lv, "LVH_CARGO_BODY_TYPE_CODE",    MmuccLookup.CARGO_BODY));
                lvl.put("hmReleasedLabel",    label(lv, "LVH_HM_RELEASED_CODE",        MmuccLookup.HM_RELEASED));

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> ssList = (List<Map<String, Object>>) lv.get("_specialSizing");
                lvl.put("specialSizingLabels", ssList == null ? "—" :
                    ssList.stream()
                        .map(r -> MmuccLookup.labelOnly(toInt(r.get("LSS_SPECIAL_SIZING_CODE")), MmuccLookup.SPECIAL_SIZING))
                        .collect(Collectors.joining(", ")));

                vl.put("lvLabels", lvl);
            }

            // Automation labels
            @SuppressWarnings("unchecked")
            Map<String, Object> aut = (Map<String, Object>) veh.get("_automation");
            if (aut != null) {
                Map<String, Object> autl = new HashMap<>();
                autl.put("automationPresentLabel", label(aut, "VAT_AUTOMATION_PRESENT_CODE", MmuccLookup.AUTOMATION_PRESENT));

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> livList = (List<Map<String, Object>>) aut.get("_levelsInVehicle");
                autl.put("levelsInVehicleLabels", livList == null ? "—" :
                    livList.stream()
                        .map(r -> MmuccLookup.labelOnly(toInt(r.get("VAI_AUTOMATION_LEVEL_CODE")), MmuccLookup.AUTOMATION_LEVEL))
                        .collect(Collectors.joining(", ")));

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> leList = (List<Map<String, Object>>) aut.get("_levelsEngaged");
                autl.put("levelsEngagedLabels", leList == null ? "—" :
                    leList.stream()
                        .map(r -> MmuccLookup.labelOnly(toInt(r.get("VAE_AUTOMATION_LEVEL_CODE")), MmuccLookup.AUTOMATION_LEVEL))
                        .collect(Collectors.joining(", ")));

                vl.put("autLabels", autl);
            }

            // Person labels list
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> persons = (List<Map<String, Object>>) veh.get("_persons");
            List<Map<String, Object>> personLabels = buildPersonLabels(persons);
            vl.put("personLabels", personLabels);

            vehicleLabels.add(vl);
        }
        model.put("vehicleLabels", vehicleLabels);

        return model;
    }

    // ── Person helpers ─────────────────────────────────────────────────────

    private List<Map<String, Object>> buildPersons(List<Map<String, Object>> personRows) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> per : personRows) {
            Long personId = toLong(per.get("PRS_PERSON_ID"));

            List<Map<String, Object>> airbags =
                jdbc.queryForList(
                    "SELECT PAB_AIRBAG_CODE FROM PERSON_AIRBAG_TBL WHERE PAB_PERSON_ID = ?", personId);
            List<Map<String, Object>> driverActions =
                jdbc.queryForList(
                    "SELECT PDA_ACTION_CODE FROM PERSON_DRIVER_ACTION_TBL WHERE PDA_PERSON_ID = ?", personId);
            List<Map<String, Object>> dlRestrictions =
                jdbc.queryForList(
                    "SELECT PDR_RESTRICTION_CODE FROM PERSON_DL_RESTRICTION_TBL WHERE PDR_PERSON_ID = ?", personId);
            List<Map<String, Object>> drugTests =
                jdbc.queryForList(
                    "SELECT DTR_RESULT_CODE FROM PERSON_DRUG_TEST_RESULT_TBL WHERE DTR_PERSON_ID = ?", personId);

            Map<String, Object> fatalSection = null;
            try {
                fatalSection = jdbc.queryForMap(
                    "SELECT * FROM FATAL_SECTION_TBL WHERE FSC_PERSON_ID = ?", personId);
            } catch (EmptyResultDataAccessException ignored) {}

            Map<String, Object> nonMotorist = null;
            try {
                nonMotorist = jdbc.queryForMap(
                    "SELECT * FROM NON_MOTORIST_TBL WHERE NMT_PERSON_ID = ?", personId);
                Long nmtId = toLong(nonMotorist.get("NMT_ID"));
                List<Map<String, Object>> safetyEq =
                    jdbc.queryForList(
                        "SELECT NMS_EQUIPMENT_CODE FROM NON_MOTORIST_SAFETY_EQUIPMENT_TBL WHERE NMS_NMT_ID = ?",
                        nmtId);
                nonMotorist.put("_safetyEquipment", safetyEq);
            } catch (EmptyResultDataAccessException ignored) {}

            Map<String, Object> personModel = new HashMap<>(per);
            personModel.put("_airbags", airbags);
            personModel.put("_driverActions", driverActions);
            personModel.put("_dlRestrictions", dlRestrictions);
            personModel.put("_drugTests", drugTests);
            personModel.put("_fatalSection", fatalSection);
            personModel.put("_nonMotorist", nonMotorist);
            result.add(personModel);
        }
        return result;
    }

    private List<Map<String, Object>> buildPersonLabels(List<Map<String, Object>> persons) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (persons == null) return result;
        for (Map<String, Object> per : persons) {
            Map<String, Object> pl = new HashMap<>();
            pl.put("sexLabel",             label(per, "PRS_SEX_CODE",              MmuccLookup.SEX_CODE));
            pl.put("personTypeLabel",      label(per, "PRS_PERSON_TYPE_CODE",      MmuccLookup.PERSON_TYPE));
            pl.put("responderLabel",       label(per, "PRS_INCIDENT_RESPONDER_CODE",MmuccLookup.INCIDENT_RESPONDER));
            pl.put("injuryStatusLabel",    label(per, "PRS_INJURY_STATUS_CODE",    MmuccLookup.INJURY_STATUS));
            pl.put("seatingRowLabel",      label(per, "PRS_SEATING_ROW_CODE",      MmuccLookup.SEATING_ROW));
            pl.put("seatingSeatLabel",     label(per, "PRS_SEATING_SEAT_CODE",     MmuccLookup.SEATING_SEAT));
            pl.put("restraintLabel",       label(per, "PRS_RESTRAINT_CODE",        MmuccLookup.RESTRAINT));
            pl.put("restraintImproperLabel",label(per, "PRS_RESTRAINT_IMPROPER_FLG",MmuccLookup.YES_NO));
            pl.put("ejectionLabel",        label(per, "PRS_EJECTION_CODE",         MmuccLookup.EJECTION));
            pl.put("dlJurisdLabel",        label(per, "PRS_DL_JURISDICTION_TYPE",  MmuccLookup.DL_JURISDICTION_TYPE));
            pl.put("dlClassLabel",         label(per, "PRS_DL_CLASS_CODE",         MmuccLookup.DL_CLASS));
            pl.put("dlIsCdlLabel",         label(per, "PRS_DL_IS_CDL_FLG",         MmuccLookup.YES_NO));
            pl.put("dlEndorsementLabel",   label(per, "PRS_DL_ENDORSEMENT_CODE",   MmuccLookup.DL_ENDORSEMENT));
            pl.put("speedingLabel",        label(per, "PRS_SPEEDING_CODE",          MmuccLookup.SPEEDING));
            pl.put("dlAlcoholLabel",       label(per, "PRS_DL_ALCOHOL_INTERLOCK_FLG",MmuccLookup.YES_NO));
            pl.put("dlStatusTypeLabel",    label(per, "PRS_DL_STATUS_TYPE_CODE",   MmuccLookup.DL_STATUS_TYPE));
            pl.put("dlStatusLabel",        label(per, "PRS_DL_STATUS_CODE",         MmuccLookup.DL_STATUS));
            pl.put("distractedActionLabel",label(per, "PRS_DISTRACTED_ACTION_CODE", MmuccLookup.DISTRACTED_ACTION));
            pl.put("distractedSourceLabel",label(per, "PRS_DISTRACTED_SOURCE_CODE", MmuccLookup.DISTRACTED_SOURCE));
            pl.put("condition1Label",      label(per, "PRS_CONDITION_CODE_1",       MmuccLookup.DRIVER_CONDITION));
            pl.put("condition2Label",      label(per, "PRS_CONDITION_CODE_2",       MmuccLookup.DRIVER_CONDITION));
            pl.put("leSuspectsAlcLabel",   label(per, "PRS_LE_SUSPECTS_ALCOHOL",   MmuccLookup.YES_NO));
            pl.put("alcTestStatusLabel",   label(per, "PRS_ALCOHOL_TEST_STATUS_CODE",MmuccLookup.ALCOHOL_TEST_STATUS));
            pl.put("alcTestTypeLabel",     label(per, "PRS_ALCOHOL_TEST_TYPE_CODE", MmuccLookup.ALCOHOL_TEST_TYPE));
            pl.put("leSuspectsDrugLabel",  label(per, "PRS_LE_SUSPECTS_DRUG",      MmuccLookup.YES_NO));
            pl.put("drugTestStatusLabel",  label(per, "PRS_DRUG_TEST_STATUS_CODE",  MmuccLookup.DRUG_TEST_STATUS));
            pl.put("drugTestTypeLabel",    label(per, "PRS_DRUG_TEST_TYPE_CODE",    MmuccLookup.DRUG_TEST_TYPE));
            pl.put("transportLabel",       label(per, "PRS_TRANSPORT_SOURCE_CODE",  MmuccLookup.TRANSPORT_SOURCE));
            pl.put("injuryAreaLabel",      label(per, "PRS_INJURY_AREA_CODE",       MmuccLookup.INJURY_AREA));
            pl.put("injurySeverityLabel",  label(per, "PRS_INJURY_SEVERITY_CODE",   MmuccLookup.INJURY_SEVERITY));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> airbagList = (List<Map<String, Object>>) per.get("_airbags");
            pl.put("airbagLabels", airbagList == null ? "—" :
                airbagList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("PAB_AIRBAG_CODE")), MmuccLookup.AIRBAG))
                    .collect(Collectors.joining(", ")));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> daList = (List<Map<String, Object>>) per.get("_driverActions");
            pl.put("driverActionLabels", daList == null ? "—" :
                daList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("PDA_ACTION_CODE")), MmuccLookup.DRIVER_ACTION))
                    .collect(Collectors.joining(", ")));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> drList = (List<Map<String, Object>>) per.get("_dlRestrictions");
            pl.put("dlRestrictionLabels", drList == null ? "—" :
                drList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("PDR_RESTRICTION_CODE")), MmuccLookup.DL_RESTRICTION))
                    .collect(Collectors.joining(", ")));

            @SuppressWarnings("unchecked")
            List<Map<String, Object>> dtList = (List<Map<String, Object>>) per.get("_drugTests");
            pl.put("drugTestResultLabels", dtList == null ? "—" :
                dtList.stream()
                    .map(r -> MmuccLookup.labelOnly(toInt(r.get("DTR_RESULT_CODE")), MmuccLookup.DRUG_TEST_RESULT))
                    .collect(Collectors.joining(", ")));

            // Fatal section labels
            @SuppressWarnings("unchecked")
            Map<String, Object> fat = (Map<String, Object>) per.get("_fatalSection");
            if (fat != null) {
                Map<String, Object> fatl = new HashMap<>();
                fatl.put("avoidanceLabel",    label(fat, "FSC_AVOIDANCE_MANEUVER_CODE",  MmuccLookup.AVOIDANCE_MANEUVER));
                fatl.put("alcTestTypeLabel",  label(fat, "FSC_ALCOHOL_TEST_TYPE_CODE",   MmuccLookup.ALCOHOL_TEST_TYPE));
                fatl.put("drugTestTypeLabel", label(fat, "FSC_DRUG_TEST_TYPE_CODE",      MmuccLookup.DRUG_TEST_TYPE));
                pl.put("fatLabels", fatl);
            }

            // Non-motorist labels
            @SuppressWarnings("unchecked")
            Map<String, Object> nm = (Map<String, Object>) per.get("_nonMotorist");
            if (nm != null) {
                Map<String, Object> nml = new HashMap<>();
                nml.put("actionCircLabel",      label(nm, "NMT_ACTION_CIRC_CODE",        MmuccLookup.NM_ACTION_CIRC));
                nml.put("originDestLabel",      label(nm, "NMT_ORIGIN_DESTINATION_CODE",  MmuccLookup.NM_ORIGIN_DESTINATION));
                nml.put("contributing1Label",   label(nm, "NMT_CONTRIBUTING_ACTION_1",    MmuccLookup.NM_CONTRIBUTING_ACTION));
                nml.put("contributing2Label",   label(nm, "NMT_CONTRIBUTING_ACTION_2",    MmuccLookup.NM_CONTRIBUTING_ACTION));
                nml.put("locationLabel",        label(nm, "NMT_LOCATION_AT_CRASH_CODE",   MmuccLookup.NM_LOCATION_AT_CRASH));
                nml.put("contactPointLabel",    label(nm, "NMT_INITIAL_CONTACT_POINT",    MmuccLookup.NM_CONTACT_POINT));

                @SuppressWarnings("unchecked")
                List<Map<String, Object>> seList = (List<Map<String, Object>>) nm.get("_safetyEquipment");
                nml.put("safetyEqLabels", seList == null ? "—" :
                    seList.stream()
                        .map(r -> MmuccLookup.labelOnly(toInt(r.get("NMS_EQUIPMENT_CODE")), MmuccLookup.NM_SAFETY_EQUIPMENT))
                        .collect(Collectors.joining(", ")));

                pl.put("nmLabels", nml);
            }

            result.add(pl);
        }
        return result;
    }

    // ── Utility ────────────────────────────────────────────────────────────

    private static String label(Map<String, Object> row, String col, Map<Integer, String> map) {
        if (row == null) return "—";
        Object val = row.get(col);
        return MmuccLookup.label(toInt(val), map);
    }

    private static String codeListLabels(List<Map<String, Object>> rows, String col,
                                          Map<Integer, String> map) {
        if (rows == null || rows.isEmpty()) return "—";
        return rows.stream()
            .map(r -> MmuccLookup.labelOnly(toInt(r.get(col)), map))
            .collect(Collectors.joining(", "));
    }

    private static Integer toInt(Object val) {
        if (val == null) return null;
        if (val instanceof Integer) return (Integer) val;
        if (val instanceof Number) return ((Number) val).intValue();
        try { return Integer.parseInt(val.toString()); }
        catch (NumberFormatException e) { return null; }
    }

    private static Long toLong(Object val) {
        if (val == null) return null;
        if (val instanceof Long) return (Long) val;
        if (val instanceof Number) return ((Number) val).longValue();
        try { return Long.parseLong(val.toString()); }
        catch (NumberFormatException e) { return null; }
    }
}
