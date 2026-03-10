package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.RoadwayRequest;
import gov.nhtsa.mmucc.crash.dto.RoadwayResponse;
import gov.nhtsa.mmucc.crash.entity.Roadway;
import gov.nhtsa.mmucc.crash.mapper.RoadwayMapper;
import gov.nhtsa.mmucc.crash.repository.RoadwayRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class RoadwayService {

    private final RoadwayRepository roadwayRepo;
    private final RoadwayMapper roadwayMapper;
    private final CrashService crashService;
    private final AuditLogService auditLogService;

    public RoadwayService(RoadwayRepository roadwayRepo,
                          RoadwayMapper roadwayMapper,
                          CrashService crashService,
                          AuditLogService auditLogService) {
        this.roadwayRepo = roadwayRepo;
        this.roadwayMapper = roadwayMapper;
        this.crashService = crashService;
        this.auditLogService = auditLogService;
    }

    // -----------------------------------------------------------------------
    // Upsert (create or replace)
    // -----------------------------------------------------------------------

    @Transactional
    public RoadwayResponse upsertRoadway(Long crashId, RoadwayRequest request, UserPrincipal actor) {
        crashService.findOrThrow(crashId);

        return roadwayRepo.findByCrashId(crashId)
                .map(existing -> updateRoadway(existing, crashId, request, actor))
                .orElseGet(() -> createRoadway(crashId, request, actor));
    }

    private RoadwayResponse createRoadway(Long crashId, RoadwayRequest request, UserPrincipal actor) {
        Roadway roadway = roadwayMapper.toEntity(request);
        roadway.setCrashId(crashId);
        setCreatedAudit(roadway.getAudit(), actor.getUsername());
        roadway = roadwayRepo.save(roadway);

        RoadwayResponse response = crashService.toRoadwayResponse(roadway);
        auditLogService.record("CREATE", "ROADWAY_TBL", roadway.getRoadwayId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    private RoadwayResponse updateRoadway(Roadway roadway, Long crashId,
                                          RoadwayRequest request, UserPrincipal actor) {
        RoadwayResponse before = crashService.toRoadwayResponse(roadway);

        roadwayMapper.updateEntityFromRequest(request, roadway);
        setModifiedAudit(roadway.getAudit(), actor.getUsername());
        roadway = roadwayRepo.save(roadway);

        RoadwayResponse after = crashService.toRoadwayResponse(roadway);
        auditLogService.record("UPDATE", "ROADWAY_TBL", roadway.getRoadwayId(),
                actor.getUsername(), crashId, before, after);
        return after;
    }

    // -----------------------------------------------------------------------
    // Read
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public RoadwayResponse getRoadway(Long crashId) {
        crashService.findOrThrow(crashId);
        return roadwayRepo.findByCrashId(crashId)
                .map(crashService::toRoadwayResponse)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "roadway for crash " + crashId));
    }

    // -----------------------------------------------------------------------
    // Delete
    // -----------------------------------------------------------------------

    @Transactional
    public void deleteRoadway(Long crashId, UserPrincipal actor) {
        crashService.findOrThrow(crashId);
        Roadway roadway = roadwayRepo.findByCrashId(crashId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "roadway for crash " + crashId));
        RoadwayResponse before = crashService.toRoadwayResponse(roadway);
        roadwayRepo.deleteByCrashId(crashId);
        auditLogService.record("DELETE", "ROADWAY_TBL", roadway.getRoadwayId(),
                actor.getUsername(), crashId, before, null);
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

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
