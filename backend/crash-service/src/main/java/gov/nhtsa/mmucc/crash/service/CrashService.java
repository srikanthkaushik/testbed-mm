package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.entity.*;
import gov.nhtsa.mmucc.crash.mapper.CrashMapper;
import gov.nhtsa.mmucc.crash.repository.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class CrashService {

    private final CrashRepository crashRepo;
    private final CrashWeatherConditionRepository weatherRepo;
    private final CrashSurfaceConditionRepository surfaceRepo;
    private final CrashContributingRoadwayRepository contributingRepo;
    private final VehicleRepository vehicleRepo;
    private final RoadwayRepository roadwayRepo;
    private final VehicleTrafficControlRepository trafficControlRepo;
    private final VehicleDamageAreaRepository damageAreaRepo;
    private final VehicleSequenceEventRepository sequenceEventRepo;
    private final CrashMapper crashMapper;
    private final AuditLogService auditLogService;

    public CrashService(CrashRepository crashRepo,
                        CrashWeatherConditionRepository weatherRepo,
                        CrashSurfaceConditionRepository surfaceRepo,
                        CrashContributingRoadwayRepository contributingRepo,
                        VehicleRepository vehicleRepo,
                        RoadwayRepository roadwayRepo,
                        VehicleTrafficControlRepository trafficControlRepo,
                        VehicleDamageAreaRepository damageAreaRepo,
                        VehicleSequenceEventRepository sequenceEventRepo,
                        CrashMapper crashMapper,
                        AuditLogService auditLogService) {
        this.crashRepo = crashRepo;
        this.weatherRepo = weatherRepo;
        this.surfaceRepo = surfaceRepo;
        this.contributingRepo = contributingRepo;
        this.vehicleRepo = vehicleRepo;
        this.roadwayRepo = roadwayRepo;
        this.trafficControlRepo = trafficControlRepo;
        this.damageAreaRepo = damageAreaRepo;
        this.sequenceEventRepo = sequenceEventRepo;
        this.crashMapper = crashMapper;
        this.auditLogService = auditLogService;
    }

    // -----------------------------------------------------------------------
    // Create
    // -----------------------------------------------------------------------

    @Transactional
    public CrashDetailResponse createCrash(CrashRequest request, UserPrincipal actor) {
        Crash crash = crashMapper.toEntity(request);
        setCreatedAudit(crash.getAudit(), actor.getUsername());
        crash = crashRepo.save(crash);

        replaceWeatherConditions(crash.getCrashId(), request.weatherConditions(), actor.getUsername());
        replaceSurfaceConditions(crash.getCrashId(), request.surfaceConditions(), actor.getUsername());
        replaceContributingCircumstances(crash.getCrashId(), request.contributingCircumstances(), actor.getUsername());

        CrashDetailResponse response = buildDetailResponse(crash);
        auditLogService.record("CREATE", "CRASH_TBL", crash.getCrashId(),
                actor.getUsername(), crash.getCrashId(), null, response);
        return response;
    }

    // -----------------------------------------------------------------------
    // Read
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public CrashDetailResponse getCrash(Long id) {
        return buildDetailResponse(findOrThrow(id));
    }

    @Transactional(readOnly = true)
    public Page<CrashSummaryResponse> listCrashes(CrashSearchFilter filter) {
        PageRequest pageable = PageRequest.of(
                filter.page(), filter.size(), Sort.by(Sort.Direction.DESC, "crashDate"));
        return crashRepo.findByFilters(
                filter.dateFrom(), filter.dateTo(), filter.severity(), filter.county(), pageable)
                .map(crashMapper::toSummary);
    }

    // -----------------------------------------------------------------------
    // Update
    // -----------------------------------------------------------------------

    @Transactional
    public CrashDetailResponse updateCrash(Long id, CrashRequest request, UserPrincipal actor) {
        Crash crash = findOrThrow(id);
        CrashDetailResponse before = buildDetailResponse(crash);

        crashMapper.updateEntityFromRequest(request, crash);
        setModifiedAudit(crash.getAudit(), actor.getUsername());
        crash = crashRepo.save(crash);

        replaceWeatherConditions(crash.getCrashId(), request.weatherConditions(), actor.getUsername());
        replaceSurfaceConditions(crash.getCrashId(), request.surfaceConditions(), actor.getUsername());
        replaceContributingCircumstances(crash.getCrashId(), request.contributingCircumstances(), actor.getUsername());

        CrashDetailResponse after = buildDetailResponse(crash);
        auditLogService.record("UPDATE", "CRASH_TBL", crash.getCrashId(),
                actor.getUsername(), crash.getCrashId(), before, after);
        return after;
    }

    // -----------------------------------------------------------------------
    // Delete
    // -----------------------------------------------------------------------

    @Transactional
    public void deleteCrash(Long id, UserPrincipal actor) {
        Crash crash = findOrThrow(id);
        CrashDetailResponse before = buildDetailResponse(crash);
        // Cascade deletes handle children in DB; JPA cascade covers what we mapped
        crashRepo.deleteById(id);
        auditLogService.record("DELETE", "CRASH_TBL", id,
                actor.getUsername(), id, before, null);
    }

    // -----------------------------------------------------------------------
    // Detail assembly (no N+1: all child fetches are batched by crashId)
    // -----------------------------------------------------------------------

    CrashDetailResponse buildDetailResponse(Crash c) {
        Long id = c.getCrashId();

        List<ChildCodeDto> weather = weatherRepo.findByCrashIdOrderBySequenceNum(id).stream()
                .map(e -> new ChildCodeDto(e.getSequenceNum(), e.getWeatherCode())).toList();

        List<ChildCodeDto> surface = surfaceRepo.findByCrashIdOrderBySequenceNum(id).stream()
                .map(e -> new ChildCodeDto(e.getSequenceNum(), e.getSurfaceCode())).toList();

        List<ChildCodeDto> contributing = contributingRepo.findByCrashIdOrderBySequenceNum(id).stream()
                .map(e -> new ChildCodeDto(e.getSequenceNum(), e.getCircumstanceCode())).toList();

        RoadwayResponse roadway = roadwayRepo.findByCrashId(id)
                .map(this::toRoadwayResponse).orElse(null);

        List<VehicleResponse> vehicles = vehicleRepo.findByCrashIdOrderByUnitNumber(id).stream()
                .map(this::toVehicleResponse).toList();

        return new CrashDetailResponse(
                c.getCrashId(), c.getCrashIdentifier(), c.getCrashTypeCode(),
                c.getFirstHarmfulEventCode(), c.getCrashDate(), c.getCrashTime(),
                c.getCountyFipsCode(), c.getCountyName(), c.getCityPlaceCode(), c.getCityPlaceName(),
                c.getRouteId(), c.getRouteTypeCode(), c.getRouteDirectionCode(),
                c.getDistanceFromRefMiles(), c.getRefPointDirectionCode(),
                c.getLatitude(), c.getLongitude(), c.getLocFirstHarmfulEvent(),
                c.getMannerCollisionCode(), c.getSourceOfInfoCode(), c.getLightConditionCode(),
                c.getJunctionInterchangeFlg(), c.getJunctionLocationCode(),
                c.getIntersectionApproaches(), c.getIntersectionGeometryCode(),
                c.getIntersectionTrafficCtl(), c.getSchoolBusRelatedCode(),
                c.getWorkZoneRelatedCode(), c.getWorkZoneLocationCode(),
                c.getWorkZoneTypeCode(), c.getWorkZoneWorkersCode(), c.getWorkZoneLawEnfCode(),
                c.getCrashSeverityCode(), c.getNumMotorVehicles(), c.getNumMotorists(),
                c.getNumNonMotorists(), c.getNumNonFatallyInjured(), c.getNumFatalities(),
                c.getAlcoholInvolvementCode(), c.getDrugInvolvementCode(), c.getDayOfWeekCode(),
                weather, surface, contributing,
                roadway, vehicles,
                c.getAudit().getCreatedBy(), c.getAudit().getCreatedDt(),
                c.getAudit().getModifiedBy(), c.getAudit().getModifiedDt()
        );
    }

    // -----------------------------------------------------------------------
    // Multi-value child helpers
    // -----------------------------------------------------------------------

    private void replaceWeatherConditions(Long crashId, List<ChildCodeDto> items, String actor) {
        weatherRepo.deleteAllByCrashId(crashId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            CrashWeatherCondition e = new CrashWeatherCondition();
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setWeatherCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            weatherRepo.save(e);
        }
    }

    private void replaceSurfaceConditions(Long crashId, List<ChildCodeDto> items, String actor) {
        surfaceRepo.deleteAllByCrashId(crashId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            CrashSurfaceCondition e = new CrashSurfaceCondition();
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setSurfaceCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            surfaceRepo.save(e);
        }
    }

    private void replaceContributingCircumstances(Long crashId, List<ChildCodeDto> items, String actor) {
        contributingRepo.deleteAllByCrashId(crashId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            CrashContributingRoadway e = new CrashContributingRoadway();
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setCircumstanceCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            contributingRepo.save(e);
        }
    }

    // -----------------------------------------------------------------------
    // Vehicle/Roadway response assemblers (used here and by VehicleService)
    // -----------------------------------------------------------------------

    VehicleResponse toVehicleResponse(Vehicle v) {
        List<TrafficControlDto> tcs = trafficControlRepo.findByVehicleIdOrderBySequenceNum(v.getVehicleId())
                .stream().map(e -> new TrafficControlDto(
                        e.getSequenceNum(), e.getTcdTypeCode(), e.getTcdInoperativeCode())).toList();
        List<ChildCodeDto> da = damageAreaRepo.findByVehicleIdOrderBySequenceNum(v.getVehicleId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getAreaCode())).toList();
        List<ChildCodeDto> se = sequenceEventRepo.findByVehicleIdOrderBySequenceNum(v.getVehicleId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getEventCode())).toList();

        return new VehicleResponse(
                v.getVehicleId(), v.getCrashId(), v.getVin(),
                v.getUnitTypeCode(), v.getUnitNumber(),
                v.getRegistrationState(), v.getRegistrationYear(), v.getLicensePlate(),
                v.getMake(), v.getModelYear(), v.getModel(),
                v.getBodyTypeCode(), v.getTrailingUnitsCount(), v.getVehicleSizeCode(),
                v.getHmPlacardFlg(), v.getTotalOccupants(), v.getSpecialFunctionCode(),
                v.getEmergencyUseCode(), v.getSpeedLimitMph(), v.getDirectionOfTravelCode(),
                v.getTrafficwayTravelDirCode(), v.getTrafficwayDividedCode(),
                v.getTrafficwayBarrierCode(), v.getTrafficwayHovHotCode(),
                v.getTrafficwayHovCrashFlg(), v.getTotalThroughLanes(), v.getTotalAuxiliaryLanes(),
                v.getRoadwayAlignmentCode(), v.getRoadwayGradeCode(), v.getManeuverCode(),
                v.getDamageInitialContact(), v.getDamageExtentCode(), v.getMostHarmfulEventCode(),
                v.getHitAndRunCode(), v.getTowedCode(), v.getContributingCircCode(),
                tcs, da, se,
                v.getAudit().getCreatedDt(), v.getAudit().getModifiedDt()
        );
    }

    RoadwayResponse toRoadwayResponse(Roadway r) {
        return new RoadwayResponse(
                r.getRoadwayId(), r.getCrashId(), r.getBridgeStructureId(),
                r.getCurveRadiusFt(), r.getCurveLengthFt(), r.getCurveSuperelevationPct(),
                r.getGradeDirection(), r.getGradePercent(),
                r.getNationalHwySysCode(), r.getFunctionalClassCode(),
                r.getAadtYear(), r.getAadtValue(), r.getAadtTruckMeasure(), r.getAadtMotorcycleMeasure(),
                r.getLaneWidthFt(), r.getLeftShoulderWidthFt(), r.getRightShoulderWidthFt(),
                r.getMedianWidthFt(), r.getAccessControlCode(), r.getRailwayCrossingId(),
                r.getRoadwayLightingCode(), r.getPavementEdgelineCode(),
                r.getPavementCenterlineCode(), r.getPavementLaneLineCode(),
                r.getBicycleFacilityCode(), r.getBicycleSignedRouteCode(),
                r.getMainlineLanesCount(), r.getCrossStreetLanesCount(),
                r.getEnteringVehiclesYear(), r.getEnteringVehiclesAadt(),
                r.getAudit().getCreatedDt(), r.getAudit().getModifiedDt()
        );
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    Crash findOrThrow(Long id) {
        return crashRepo.findById(id)
                .orElseThrow(() -> new MmuccException.UserNotFoundException("crash " + id));
    }

    private void setCreatedAudit(AuditFields audit, String actor) {
        audit.setCreatedBy(actor);
        audit.setCreatedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("CREATE");
    }

    private void setModifiedAudit(AuditFields audit, String actor) {
        audit.setModifiedBy(actor);
        audit.setModifiedDt(LocalDateTime.now());
        audit.setLastUpdatedActivityCode("UPDATE");
    }
}
