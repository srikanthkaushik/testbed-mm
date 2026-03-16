package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.ChildCodeDto;
import gov.nhtsa.mmucc.crash.dto.LargeVehicleRequest;
import gov.nhtsa.mmucc.crash.dto.LargeVehicleResponse;
import gov.nhtsa.mmucc.crash.entity.LargeVehicle;
import gov.nhtsa.mmucc.crash.entity.LvSpecialSizing;
import gov.nhtsa.mmucc.crash.mapper.LargeVehicleMapper;
import gov.nhtsa.mmucc.crash.repository.LargeVehicleRepository;
import gov.nhtsa.mmucc.crash.repository.LvSpecialSizingRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class LargeVehicleService {

    private final LargeVehicleRepository largeVehicleRepo;
    private final LvSpecialSizingRepository specialSizingRepo;
    private final LargeVehicleMapper largeVehicleMapper;
    private final VehicleService vehicleService;
    private final AuditLogService auditLogService;

    public LargeVehicleService(LargeVehicleRepository largeVehicleRepo,
                                LvSpecialSizingRepository specialSizingRepo,
                                LargeVehicleMapper largeVehicleMapper,
                                VehicleService vehicleService,
                                AuditLogService auditLogService) {
        this.largeVehicleRepo = largeVehicleRepo;
        this.specialSizingRepo = specialSizingRepo;
        this.largeVehicleMapper = largeVehicleMapper;
        this.vehicleService = vehicleService;
        this.auditLogService = auditLogService;
    }

    @Transactional(readOnly = true)
    public LargeVehicleResponse getLargeVehicle(Long crashId, Long vehicleId) {
        vehicleService.findOrThrow(crashId, vehicleId);
        LargeVehicle lv = largeVehicleRepo.findByVehicleId(vehicleId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "large vehicle section for vehicle " + vehicleId));
        return toLargeVehicleResponse(lv);
    }

    @Transactional
    public LargeVehicleResponse upsertLargeVehicle(Long crashId, Long vehicleId,
                                                    LargeVehicleRequest request, UserPrincipal actor) {
        vehicleService.findOrThrow(crashId, vehicleId);

        LargeVehicle lv = largeVehicleRepo.findByVehicleId(vehicleId).orElse(null);
        if (lv == null) {
            lv = largeVehicleMapper.toEntity(request);
            lv.setVehicleId(vehicleId);
            lv.setCrashId(crashId);
            setCreatedAudit(lv.getAudit(), actor.getUsername());
        } else {
            largeVehicleMapper.updateEntityFromRequest(request, lv);
            setModifiedAudit(lv.getAudit(), actor.getUsername());
        }
        lv = largeVehicleRepo.save(lv);

        replaceSpecialSizing(lv.getId(), crashId, request.specialSizing(), actor.getUsername());

        LargeVehicleResponse response = toLargeVehicleResponse(lv);
        auditLogService.record("CREATE", "LARGE_VEHICLE_TBL", lv.getId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    @Transactional
    public void deleteLargeVehicle(Long crashId, Long vehicleId, UserPrincipal actor) {
        vehicleService.findOrThrow(crashId, vehicleId);
        LargeVehicle lv = largeVehicleRepo.findByVehicleId(vehicleId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "large vehicle section for vehicle " + vehicleId));
        specialSizingRepo.deleteAllByLvhId(lv.getId());
        largeVehicleRepo.deleteById(lv.getId());
        auditLogService.record("DELETE", "LARGE_VEHICLE_TBL", lv.getId(),
                actor.getUsername(), crashId, toLargeVehicleResponse(lv), null);
    }

    LargeVehicleResponse toLargeVehicleResponse(LargeVehicle lv) {
        List<ChildCodeDto> sizing = specialSizingRepo.findByLvhIdOrderBySequenceNum(lv.getId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getSizingCode())).toList();
        return new LargeVehicleResponse(
                lv.getId(), lv.getVehicleId(), lv.getCrashId(),
                lv.getCmvLicenseStatusCode(), lv.getCdlComplianceCode(),
                lv.getTrailer1Plate(), lv.getTrailer2Plate(), lv.getTrailer3Plate(),
                lv.getTrailer1Vin(), lv.getTrailer2Vin(), lv.getTrailer3Vin(),
                lv.getTrailer1Make(), lv.getTrailer2Make(), lv.getTrailer3Make(),
                lv.getTrailer1Model(), lv.getTrailer2Model(), lv.getTrailer3Model(),
                lv.getTrailer1Year(), lv.getTrailer2Year(), lv.getTrailer3Year(),
                lv.getCarrierIdTypeCode(), lv.getCarrierCountryState(),
                lv.getCarrierIdNumber(), lv.getCarrierName(),
                lv.getCarrierStreet1(), lv.getCarrierStreet2(), lv.getCarrierCity(),
                lv.getCarrierState(), lv.getCarrierZip(), lv.getCarrierCountry(),
                lv.getCarrierTypeCode(),
                lv.getVehicleConfigCode(), lv.getVehiclePermittedCode(), lv.getCargoBodyTypeCode(),
                lv.getHmId(), lv.getHmClass(), lv.getHmReleasedCode(),
                lv.getAxlesTractor(), lv.getAxlesTrailer1(), lv.getAxlesTrailer2(), lv.getAxlesTrailer3(),
                sizing,
                lv.getAudit().getCreatedDt(), lv.getAudit().getModifiedDt()
        );
    }

    private void replaceSpecialSizing(Long lvhId, Long crashId, List<ChildCodeDto> items, String actor) {
        specialSizingRepo.deleteAllByLvhId(lvhId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            LvSpecialSizing e = new LvSpecialSizing();
            e.setLvhId(lvhId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setSizingCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            specialSizingRepo.save(e);
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
