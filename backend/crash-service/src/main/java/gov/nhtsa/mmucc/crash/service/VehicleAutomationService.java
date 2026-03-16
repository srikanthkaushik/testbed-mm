package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.ChildCodeDto;
import gov.nhtsa.mmucc.crash.dto.VehicleAutomationRequest;
import gov.nhtsa.mmucc.crash.dto.VehicleAutomationResponse;
import gov.nhtsa.mmucc.crash.entity.VehicleAutomation;
import gov.nhtsa.mmucc.crash.entity.VehicleAutomationLevelEngaged;
import gov.nhtsa.mmucc.crash.entity.VehicleAutomationLevelInVehicle;
import gov.nhtsa.mmucc.crash.mapper.VehicleAutomationMapper;
import gov.nhtsa.mmucc.crash.repository.VehicleAutomationLevelEngagedRepository;
import gov.nhtsa.mmucc.crash.repository.VehicleAutomationLevelInVehicleRepository;
import gov.nhtsa.mmucc.crash.repository.VehicleAutomationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class VehicleAutomationService {

    private final VehicleAutomationRepository automationRepo;
    private final VehicleAutomationLevelInVehicleRepository levelsInVehicleRepo;
    private final VehicleAutomationLevelEngagedRepository levelsEngagedRepo;
    private final VehicleAutomationMapper automationMapper;
    private final VehicleService vehicleService;
    private final AuditLogService auditLogService;

    public VehicleAutomationService(VehicleAutomationRepository automationRepo,
                                     VehicleAutomationLevelInVehicleRepository levelsInVehicleRepo,
                                     VehicleAutomationLevelEngagedRepository levelsEngagedRepo,
                                     VehicleAutomationMapper automationMapper,
                                     VehicleService vehicleService,
                                     AuditLogService auditLogService) {
        this.automationRepo = automationRepo;
        this.levelsInVehicleRepo = levelsInVehicleRepo;
        this.levelsEngagedRepo = levelsEngagedRepo;
        this.automationMapper = automationMapper;
        this.vehicleService = vehicleService;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public VehicleAutomationResponse getAutomation(Long crashId, Long vehicleId) {
        vehicleService.findOrThrow(crashId, vehicleId);
        VehicleAutomation va = automationRepo.findByVehicleId(vehicleId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "automation section for vehicle " + vehicleId));
        return toAutomationResponse(va);
    }

    @Transactional
    public VehicleAutomationResponse upsertAutomation(Long crashId, Long vehicleId,
                                                       VehicleAutomationRequest request, UserPrincipal actor) {
        vehicleService.findOrThrow(crashId, vehicleId);

        VehicleAutomation va = automationRepo.findByVehicleId(vehicleId).orElse(null);
        if (va == null) {
            va = automationMapper.toEntity(request);
            va.setVehicleId(vehicleId);
            va.setCrashId(crashId);
            setCreatedAudit(va.getAudit(), actor.getUsername());
        } else {
            automationMapper.updateEntityFromRequest(request, va);
            setModifiedAudit(va.getAudit(), actor.getUsername());
        }
        va = automationRepo.save(va);

        replaceLevelsInVehicle(va.getId(), crashId, request.levelsInVehicle(), actor.getUsername());
        replaceLevelsEngaged(va.getId(), crashId, request.levelsEngaged(), actor.getUsername());

        VehicleAutomationResponse response = toAutomationResponse(va);
        auditLogService.record("CREATE", "VEHICLE_AUTOMATION_TBL", va.getId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    @Transactional
    public void deleteAutomation(Long crashId, Long vehicleId, UserPrincipal actor) {
        vehicleService.findOrThrow(crashId, vehicleId);
        VehicleAutomation va = automationRepo.findByVehicleId(vehicleId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "automation section for vehicle " + vehicleId));
        levelsInVehicleRepo.deleteAllByVatId(va.getId());
        levelsEngagedRepo.deleteAllByVatId(va.getId());
        automationRepo.deleteById(va.getId());
        auditLogService.record("DELETE", "VEHICLE_AUTOMATION_TBL", va.getId(),
                actor.getUsername(), crashId, toAutomationResponse(va), null);
    }

    VehicleAutomationResponse toAutomationResponse(VehicleAutomation va) {
        List<ChildCodeDto> inVehicle = levelsInVehicleRepo.findByVatIdOrderBySequenceNum(va.getId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getAutomationLevelCode())).toList();
        List<ChildCodeDto> engaged = levelsEngagedRepo.findByVatIdOrderBySequenceNum(va.getId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getAutomationLevelCode())).toList();
        return new VehicleAutomationResponse(
                va.getId(), va.getVehicleId(), va.getCrashId(),
                va.getAutomationPresentCode(),
                inVehicle, engaged,
                va.getAudit().getCreatedDt(), va.getAudit().getModifiedDt()
        );
    }

    private void replaceLevelsInVehicle(Long vatId, Long crashId, List<ChildCodeDto> items, String actor) {
        levelsInVehicleRepo.deleteAllByVatId(vatId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            VehicleAutomationLevelInVehicle e = new VehicleAutomationLevelInVehicle();
            e.setVatId(vatId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setAutomationLevelCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            levelsInVehicleRepo.save(e);
        }
    }

    private void replaceLevelsEngaged(Long vatId, Long crashId, List<ChildCodeDto> items, String actor) {
        levelsEngagedRepo.deleteAllByVatId(vatId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            VehicleAutomationLevelEngaged e = new VehicleAutomationLevelEngaged();
            e.setVatId(vatId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setAutomationLevelCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            levelsEngagedRepo.save(e);
        }
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
