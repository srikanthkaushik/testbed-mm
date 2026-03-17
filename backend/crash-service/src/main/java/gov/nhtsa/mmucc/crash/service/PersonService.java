package gov.nhtsa.mmucc.crash.service;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import gov.nhtsa.mmucc.common.exception.MmuccException;
import gov.nhtsa.mmucc.common.security.UserPrincipal;
import gov.nhtsa.mmucc.crash.dto.*;
import gov.nhtsa.mmucc.crash.entity.*;
import gov.nhtsa.mmucc.crash.mapper.FatalSectionMapper;
import gov.nhtsa.mmucc.crash.mapper.NonMotoristMapper;
import gov.nhtsa.mmucc.crash.mapper.PersonMapper;
import gov.nhtsa.mmucc.crash.repository.*;
import gov.nhtsa.mmucc.crash.validation.MmuccValidator;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class PersonService {

    private final PersonRepository personRepo;
    private final PersonAirbagRepository airbagRepo;
    private final PersonDriverActionRepository driverActionRepo;
    private final PersonDlRestrictionRepository dlRestrictionRepo;
    private final PersonDrugTestResultRepository drugTestResultRepo;
    private final FatalSectionRepository fatalSectionRepo;
    private final NonMotoristRepository nonMotoristRepo;
    private final NonMotoristSafetyEquipmentRepository safetyEquipmentRepo;
    private final PersonMapper personMapper;
    private final FatalSectionMapper fatalSectionMapper;
    private final NonMotoristMapper nonMotoristMapper;
    private final VehicleService vehicleService;
    private final AuditLogService auditLogService;
    private final MmuccValidator validator;

    public PersonService(PersonRepository personRepo,
                         PersonAirbagRepository airbagRepo,
                         PersonDriverActionRepository driverActionRepo,
                         PersonDlRestrictionRepository dlRestrictionRepo,
                         PersonDrugTestResultRepository drugTestResultRepo,
                         FatalSectionRepository fatalSectionRepo,
                         NonMotoristRepository nonMotoristRepo,
                         NonMotoristSafetyEquipmentRepository safetyEquipmentRepo,
                         PersonMapper personMapper,
                         FatalSectionMapper fatalSectionMapper,
                         NonMotoristMapper nonMotoristMapper,
                         VehicleService vehicleService,
                         AuditLogService auditLogService,
                         MmuccValidator validator) {
        this.personRepo = personRepo;
        this.airbagRepo = airbagRepo;
        this.driverActionRepo = driverActionRepo;
        this.dlRestrictionRepo = dlRestrictionRepo;
        this.drugTestResultRepo = drugTestResultRepo;
        this.fatalSectionRepo = fatalSectionRepo;
        this.nonMotoristRepo = nonMotoristRepo;
        this.safetyEquipmentRepo = safetyEquipmentRepo;
        this.personMapper = personMapper;
        this.fatalSectionMapper = fatalSectionMapper;
        this.nonMotoristMapper = nonMotoristMapper;
        this.vehicleService = vehicleService;
        this.auditLogService = auditLogService;
        this.validator = validator;
    }

    // -----------------------------------------------------------------------
    // Create
    // -----------------------------------------------------------------------

    @Transactional
    public PersonResponse createPerson(Long crashId, Long vehicleId, PersonRequest request, UserPrincipal actor) {
        validator.validatePerson(request);
        vehicleService.findOrThrow(crashId, vehicleId);

        Person person = personMapper.toEntity(request);
        person.setCrashId(crashId);
        person.setVehicleId(vehicleId);
        setCreatedAudit(person.getAudit(), actor.getUsername());
        person = personRepo.save(person);

        replaceAirbags(person.getPersonId(), crashId, request.airbags(), actor.getUsername());
        replaceDriverActions(person.getPersonId(), crashId, request.driverActions(), actor.getUsername());
        replaceDlRestrictions(person.getPersonId(), crashId, request.dlRestrictions(), actor.getUsername());
        replaceDrugTestResults(person.getPersonId(), crashId, request.drugTestResults(), actor.getUsername());

        PersonResponse response = toPersonResponse(person);
        auditLogService.record("CREATE", "PERSON_TBL", person.getPersonId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    // -----------------------------------------------------------------------
    // Read
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public List<PersonResponse> listPersons(Long crashId, Long vehicleId) {
        vehicleService.findOrThrow(crashId, vehicleId);
        return personRepo.findByVehicleIdOrderByPersonId(vehicleId).stream()
                .map(this::toPersonResponse).toList();
    }

    @Transactional(readOnly = true)
    public PersonResponse getPerson(Long crashId, Long vehicleId, Long personId) {
        return toPersonResponse(findOrThrow(crashId, vehicleId, personId));
    }

    // -----------------------------------------------------------------------
    // Update
    // -----------------------------------------------------------------------

    @Transactional
    public PersonResponse updatePerson(Long crashId, Long vehicleId, Long personId,
                                       PersonRequest request, UserPrincipal actor) {
        validator.validatePerson(request);
        Person person = findOrThrow(crashId, vehicleId, personId);
        PersonResponse before = toPersonResponse(person);

        personMapper.updateEntityFromRequest(request, person);
        setModifiedAudit(person.getAudit(), actor.getUsername());
        person = personRepo.save(person);

        replaceAirbags(person.getPersonId(), crashId, request.airbags(), actor.getUsername());
        replaceDriverActions(person.getPersonId(), crashId, request.driverActions(), actor.getUsername());
        replaceDlRestrictions(person.getPersonId(), crashId, request.dlRestrictions(), actor.getUsername());
        replaceDrugTestResults(person.getPersonId(), crashId, request.drugTestResults(), actor.getUsername());

        PersonResponse after = toPersonResponse(person);
        auditLogService.record("UPDATE", "PERSON_TBL", person.getPersonId(),
                actor.getUsername(), crashId, before, after);
        return after;
    }

    // -----------------------------------------------------------------------
    // Delete
    // -----------------------------------------------------------------------

    @Transactional
    public void deletePerson(Long crashId, Long vehicleId, Long personId, UserPrincipal actor) {
        Person person = findOrThrow(crashId, vehicleId, personId);
        PersonResponse before = toPersonResponse(person);

        airbagRepo.deleteAllByPersonId(personId);
        driverActionRepo.deleteAllByPersonId(personId);
        dlRestrictionRepo.deleteAllByPersonId(personId);
        drugTestResultRepo.deleteAllByPersonId(personId);
        fatalSectionRepo.deleteByPersonId(personId);
        nonMotoristRepo.deleteByPersonId(personId);
        personRepo.deleteById(personId);

        auditLogService.record("DELETE", "PERSON_TBL", personId,
                actor.getUsername(), crashId, before, null);
    }

    // -----------------------------------------------------------------------
    // Fatal Section
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public FatalSectionResponse getFatalSection(Long crashId, Long vehicleId, Long personId) {
        findOrThrow(crashId, vehicleId, personId);
        FatalSection fs = fatalSectionRepo.findByPersonId(personId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "fatal section for person " + personId));
        return toFatalSectionResponse(fs);
    }

    @Transactional
    public FatalSectionResponse upsertFatalSection(Long crashId, Long vehicleId, Long personId,
                                                    FatalSectionRequest request, UserPrincipal actor) {
        findOrThrow(crashId, vehicleId, personId);

        FatalSection fs = fatalSectionRepo.findByPersonId(personId).orElse(null);
        if (fs == null) {
            fs = fatalSectionMapper.toEntity(request);
            fs.setPersonId(personId);
            fs.setCrashId(crashId);
            setCreatedAudit(fs.getAudit(), actor.getUsername());
        } else {
            FatalSectionResponse before = toFatalSectionResponse(fs);
            fatalSectionMapper.updateEntityFromRequest(request, fs);
            setModifiedAudit(fs.getAudit(), actor.getUsername());
            auditLogService.record("UPDATE", "FATAL_SECTION_TBL", fs.getId(),
                    actor.getUsername(), crashId, before, null);
        }
        fs = fatalSectionRepo.save(fs);
        FatalSectionResponse response = toFatalSectionResponse(fs);
        auditLogService.record("CREATE", "FATAL_SECTION_TBL", fs.getId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    @Transactional
    public void deleteFatalSection(Long crashId, Long vehicleId, Long personId, UserPrincipal actor) {
        findOrThrow(crashId, vehicleId, personId);
        FatalSection fs = fatalSectionRepo.findByPersonId(personId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "fatal section for person " + personId));
        fatalSectionRepo.deleteById(fs.getId());
        auditLogService.record("DELETE", "FATAL_SECTION_TBL", fs.getId(),
                actor.getUsername(), crashId, toFatalSectionResponse(fs), null);
    }

    // -----------------------------------------------------------------------
    // Non-Motorist Section
    // -----------------------------------------------------------------------

    @Transactional(readOnly = true)
    public NonMotoristResponse getNonMotorist(Long crashId, Long vehicleId, Long personId) {
        findOrThrow(crashId, vehicleId, personId);
        NonMotorist nm = nonMotoristRepo.findByPersonId(personId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "non-motorist section for person " + personId));
        return toNonMotoristResponse(nm);
    }

    @Transactional
    public NonMotoristResponse upsertNonMotorist(Long crashId, Long vehicleId, Long personId,
                                                  NonMotoristRequest request, UserPrincipal actor) {
        findOrThrow(crashId, vehicleId, personId);

        NonMotorist nm = nonMotoristRepo.findByPersonId(personId).orElse(null);
        if (nm == null) {
            nm = nonMotoristMapper.toEntity(request);
            nm.setPersonId(personId);
            nm.setCrashId(crashId);
            setCreatedAudit(nm.getAudit(), actor.getUsername());
        } else {
            nonMotoristMapper.updateEntityFromRequest(request, nm);
            setModifiedAudit(nm.getAudit(), actor.getUsername());
        }
        nm = nonMotoristRepo.save(nm);

        replaceSafetyEquipment(nm.getId(), crashId, request.safetyEquipment(), actor.getUsername());

        NonMotoristResponse response = toNonMotoristResponse(nm);
        auditLogService.record("CREATE", "NON_MOTORIST_TBL", nm.getId(),
                actor.getUsername(), crashId, null, response);
        return response;
    }

    @Transactional
    public void deleteNonMotorist(Long crashId, Long vehicleId, Long personId, UserPrincipal actor) {
        findOrThrow(crashId, vehicleId, personId);
        NonMotorist nm = nonMotoristRepo.findByPersonId(personId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "non-motorist section for person " + personId));
        safetyEquipmentRepo.deleteAllByNmtId(nm.getId());
        nonMotoristRepo.deleteById(nm.getId());
        auditLogService.record("DELETE", "NON_MOTORIST_TBL", nm.getId(),
                actor.getUsername(), crashId, toNonMotoristResponse(nm), null);
    }

    // -----------------------------------------------------------------------
    // Response assemblers
    // -----------------------------------------------------------------------

    PersonResponse toPersonResponse(Person p) {
        List<ChildCodeDto> airbags = airbagRepo.findByPersonIdOrderBySequenceNum(p.getPersonId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getAirbagCode())).toList();
        List<ChildCodeDto> actions = driverActionRepo.findByPersonIdOrderBySequenceNum(p.getPersonId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getActionCode())).toList();
        List<ChildCodeDto> restrictions = dlRestrictionRepo.findByPersonIdOrderBySequenceNum(p.getPersonId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getRestrictionCode())).toList();
        List<PersonDrugTestDto> drugTests = drugTestResultRepo.findByPersonIdOrderBySequenceNum(p.getPersonId())
                .stream().map(e -> new PersonDrugTestDto(e.getSequenceNum(), e.getResultCode())).toList();

        return new PersonResponse(
                p.getPersonId(), p.getCrashId(), p.getVehicleId(),
                p.getPersonName(),
                p.getDobYear(), p.getDobMonth(), p.getDobDay(), p.getAgeYears(),
                p.getSexCode(),
                p.getPersonTypeCode(), p.getIncidentResponderCode(),
                p.getInjuryStatusCode(),
                p.getVehicleUnitNumber(),
                p.getSeatingRowCode(), p.getSeatingSeatCode(),
                p.getRestraintCode(), p.getRestraintImproperFlg(),
                airbags,
                p.getEjectionCode(),
                p.getDlJurisdictionType(), p.getDlJurisdictionCode(),
                p.getDlNumber(), p.getDlClassCode(), p.getDlIsCdlFlg(), p.getDlEndorsementCode(),
                p.getSpeedingCode(),
                actions,
                p.getViolationCode1(), p.getViolationCode2(),
                restrictions, p.getDlAlcoholInterlockFlg(),
                p.getDlStatusTypeCode(), p.getDlStatusCode(),
                p.getDistractedActionCode(), p.getDistractedSourceCode(),
                p.getConditionCode1(), p.getConditionCode2(),
                p.getLeSuspectsAlcohol(),
                p.getAlcoholTestStatusCode(), p.getAlcoholTestTypeCode(), p.getAlcoholBacResult(),
                p.getLeSuspectsDrug(),
                p.getDrugTestStatusCode(), p.getDrugTestTypeCode(),
                drugTests,
                p.getTransportSourceCode(), p.getEmsAgencyId(), p.getEmsRunNumber(), p.getMedicalFacility(),
                p.getInjuryAreaCode(),
                p.getInjuryDiagnosis(),
                p.getInjurySeverityCode(),
                p.getAudit().getCreatedDt(), p.getAudit().getModifiedDt()
        );
    }

    private FatalSectionResponse toFatalSectionResponse(FatalSection fs) {
        return new FatalSectionResponse(
                fs.getId(), fs.getPersonId(), fs.getCrashId(),
                fs.getAvoidanceManeuverCode(),
                fs.getAlcoholTestTypeCode(), fs.getAlcoholTestResult(),
                fs.getDrugTestTypeCode(), fs.getDrugTestResult(),
                fs.getAudit().getCreatedDt(), fs.getAudit().getModifiedDt()
        );
    }

    NonMotoristResponse toNonMotoristResponse(NonMotorist nm) {
        List<ChildCodeDto> equipment = safetyEquipmentRepo.findByNmtIdOrderBySequenceNum(nm.getId())
                .stream().map(e -> new ChildCodeDto(e.getSequenceNum(), e.getEquipmentCode())).toList();
        return new NonMotoristResponse(
                nm.getId(), nm.getPersonId(), nm.getCrashId(),
                nm.getStrikingVehicleUnit(),
                nm.getActionCircCode(), nm.getOriginDestinationCode(),
                nm.getContributingAction1(), nm.getContributingAction2(),
                nm.getLocationAtCrashCode(),
                nm.getInitialContactPoint(),
                equipment,
                nm.getAudit().getCreatedDt(), nm.getAudit().getModifiedDt()
        );
    }

    // -----------------------------------------------------------------------
    // Multi-value child helpers
    // -----------------------------------------------------------------------

    private void replaceAirbags(Long personId, Long crashId, List<ChildCodeDto> items, String actor) {
        airbagRepo.deleteAllByPersonId(personId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            PersonAirbag e = new PersonAirbag();
            e.setPersonId(personId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setAirbagCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            airbagRepo.save(e);
        }
    }

    private void replaceDriverActions(Long personId, Long crashId, List<ChildCodeDto> items, String actor) {
        driverActionRepo.deleteAllByPersonId(personId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            PersonDriverAction e = new PersonDriverAction();
            e.setPersonId(personId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setActionCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            driverActionRepo.save(e);
        }
    }

    private void replaceDlRestrictions(Long personId, Long crashId, List<ChildCodeDto> items, String actor) {
        dlRestrictionRepo.deleteAllByPersonId(personId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            PersonDlRestriction e = new PersonDlRestriction();
            e.setPersonId(personId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setRestrictionCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            dlRestrictionRepo.save(e);
        }
    }

    private void replaceDrugTestResults(Long personId, Long crashId, List<PersonDrugTestDto> items, String actor) {
        drugTestResultRepo.deleteAllByPersonId(personId);
        if (items == null) return;
        for (PersonDrugTestDto dto : items) {
            PersonDrugTestResult e = new PersonDrugTestResult();
            e.setPersonId(personId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setResultCode(dto.resultCode());
            setCreatedAudit(e.getAudit(), actor);
            drugTestResultRepo.save(e);
        }
    }

    private void replaceSafetyEquipment(Long nmtId, Long crashId, List<ChildCodeDto> items, String actor) {
        safetyEquipmentRepo.deleteAllByNmtId(nmtId);
        if (items == null) return;
        for (ChildCodeDto dto : items) {
            NonMotoristSafetyEquipment e = new NonMotoristSafetyEquipment();
            e.setNmtId(nmtId);
            e.setCrashId(crashId);
            e.setSequenceNum(dto.sequenceNum());
            e.setEquipmentCode(dto.code());
            setCreatedAudit(e.getAudit(), actor);
            safetyEquipmentRepo.save(e);
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------

    Person findOrThrow(Long crashId, Long vehicleId, Long personId) {
        // Verify vehicle belongs to crash
        vehicleService.findOrThrow(crashId, vehicleId);
        return personRepo.findByPersonIdAndVehicleId(personId, vehicleId)
                .orElseThrow(() -> new MmuccException.UserNotFoundException(
                        "person " + personId + " in vehicle " + vehicleId));
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
