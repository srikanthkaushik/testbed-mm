package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.entity.*;
import gov.nhtsa.mmucc.crash.mapper.VehicleMapper;
import gov.nhtsa.mmucc.crash.repository.*;
import gov.nhtsa.mmucc.crash.validation.MmuccValidator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class VehicleService {

    private final VehicleRepository vehicleRepo;
    private final VehicleTrafficControlRepository trafficControlRepo;
    private final VehicleDamageAreaRepository damageAreaRepo;
    private final VehicleSequenceEventRepository sequenceEventRepo;
    private final VehicleMapper vehicleMapper;
    private final CrashService crashService;
    private final AuditLogService auditLogService;
    private final MmuccValidator validator;

    public VehicleService(VehicleRepository vehicleRepo,
                          VehicleTrafficControlRepository trafficControlRepo,
                          VehicleDamageAreaRepository damageAreaRepo,
                          VehicleSequenceEventRepository sequenceEventRepo,
                          VehicleMapper vehicleMapper,
                          CrashService crashService,
                          AuditLogService auditLogService,
                          MmuccValidator validator) {
        this.vehicleRepo = vehicleRepo;
        this.trafficControlRepo = trafficControlRepo;
        this.damageAreaRepo = damageAreaRepo;
        this.sequenceEventRepo = sequenceEventRepo;
        this.vehicleMapper = vehicleMapper;
        this.crashService = crashService;
        this.auditLogService = auditLogService;
        this.validator = validator;
    }

    // -----------------------------------------------------------------------
    // Create
    // -----------------------------------------------------------------------

    @Transactional
    public VehicleResponse createVehicle(Long crashId, VehicleRequest request, UserPrincipal actor) {
        validator.validateVehicle(request);
        // Verify crash exists
        crashService.findOrThrow(crashId);

        Vehicle vehicle = vehicleMapper.toEntity(request);
        vehicle.setCrashId(crashId);
        setCreatedAudit(vehicle.getAudit(), actor.getUsername());
        vehicle = vehicleRepo.save(vehicle);

        replaceTrafficControls(vehicle.getVehicleId(), crashId, request.trafficControls(), actor.getUsername());
        replaceDamageAreas(vehicle.getVehicleId(), crashId, request.damageAreas(), actor.getUsername());
        replaceSequenceEvents(vehicle.getVehicleId(), crashId, request.sequenceEvents(), actor.getUsername());

        VehicleResponse response = crashService.toVehicleResponse(vehicle);
        auditLogService.record("CREATE", "VEHICLE_TBL", vehicle.getVehicleId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    // -----------------------------------------------------------------------
    // Read
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public List<VehicleResponse> listVehicles(Long crashId) {
        crashService.findOrThrow(crashId);
        return vehicleRepo.findByCrashIdOrderByUnitNumber(crashId).stream()
                .map(crashService::toVehicleResponse).toList();
    }

    @Transactional(readOnly = true)
    public VehicleResponse getVehicle(Long crashId, Long vehicleId) {
        return crashService.toVehicleResponse(findOrThrow(crashId, vehicleId));
    }

    // -----------------------------------------------------------------------
    // Update
    // -----------------------------------------------------------------------

    @Transactional
    public VehicleResponse updateVehicle(Long crashId, Long vehicleId,
                                         VehicleRequest request, UserPrincipal actor) {
        validator.validateVehicle(request);
        Vehicle vehicle = findOrThrow(crashId, vehicleId);
        VehicleResponse before = crashService.toVehicleResponse(vehicle);

        vehicleMapper.updateEntityFromRequest(request, vehicle);
        setModifiedAudit(vehicle.getAudit(), actor.getUsername());
        vehicle = vehicleRepo.save(vehicle);

        replaceTrafficControls(vehicle.getVehicleId(), crashId, request.trafficControls(), actor.getUsername());
        replaceDamageAreas(vehicle.getVehicleId(), crashId, request.damageAreas(), actor.getUsername());
        replaceSequenceEvents(vehicle.getVehicleId(), crashId, request.sequenceEvents(), actor.getUsername());

        VehicleResponse after = crashService.toVehicleResponse(vehicle);
        auditLogService.record("UPDATE", "VEHICLE_TBL", vehicle.getVehicleId(),
                actor.getUsername(), crashId, before, after);
        return after;
    }

    // -----------------------------------------------------------------------
    // Delete
    // -----------------------------------------------------------------------

    @Transactional
    public void deleteVehicle(Long crashId, Long vehicleId, UserPrincipal actor) {
        Vehicle vehicle = findOrThrow(crashId, vehicleId);
        VehicleResponse before = crashService.toVehicleResponse(vehicle);

        trafficControlRepo.deleteAllByVehicleId(vehicleId);
        damageAreaRepo.deleteAllByVehicleId(vehicleId);
        sequenceEventRepo.deleteAllByVehicleId(vehicleId);
        vehicleRepo.deleteById(vehicleId);

        auditLogService.record("DELETE", "VEHICLE_TBL", vehicleId,
                actor.getUsername(), crashId, before, null);
    }

    // -----------------------------------------------------------------------
    // Multi-value child helpers
    // -----------------------------------------------------------------------

    private void replaceTrafficControls(Long vehicleId, Long crashId,
                                        List<TrafficControlDto> items, String actor) {
        trafficControlRepo.deleteAllByVehicleId(vehicleId);
        if (items == null) return;
        for (TrafficControlDto dto : items) {
            VehicleTrafficControl e = new VehicleTrafficControl();
            e.setVehicleId(vehicleId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setTcdTypeCode(dto.tcdTypeCode());
            e.setTcdInoperativeCode(dto.tcdInoperativeCode());
            setCreatedAudit(e.getAudit(), actor);
            trafficControlRepo.save(e);
        }
    }

    private void replaceDamageAreas(Long vehicleId, Long crashId,
                                    List<ChildCodeDto> items, String actor) {
        damageAreaRepo.deleteAllByVehicleId(vehicleId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            VehicleDamageArea e = new VehicleDamageArea();
            e.setVehicleId(vehicleId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setAreaCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            damageAreaRepo.save(e);
        }
    }

    private void replaceSequenceEvents(Long vehicleId, Long crashId,
                                       List<ChildCodeDto> items, String actor) {
        sequenceEventRepo.deleteAllByVehicleId(vehicleId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            VehicleSequenceEvent e = new VehicleSequenceEvent();
            e.setVehicleId(vehicleId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setEventCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            sequenceEventRepo.save(e);
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    Vehicle findOrThrow(Long crashId, Long vehicleId) {
        return vehicleRepo.findByVehicleIdAndCrashId(vehicleId, crashId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "vehicle " + vehicleId + " in crash " + crashId));
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
