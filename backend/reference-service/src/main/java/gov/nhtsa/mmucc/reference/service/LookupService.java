package gov.nhtsa.mmucc.reference.service;

import gov.nhtsa.mmucc.reference.dto.LookupEntryDto;
import gov.nhtsa.mmucc.reference.entity.*;
import gov.nhtsa.mmucc.reference.repository.*;
import jakarta.annotation.PostConstruct;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

/**
 * Loads all 7 REF_* tables once at startup and serves them from an in-memory
 * map. Reference data changes very rarely; a service restart picks up any edits.
 */
@Service
public class LookupService {

    private final RefCrashTypeRepository      crashTypeRepo;
    private final RefHarmfulEventRepository   harmfulEventRepo;
    private final RefWeatherConditionRepository weatherConditionRepo;
    private final RefSurfaceConditionRepository surfaceConditionRepo;
    private final RefPersonTypeRepository     personTypeRepo;
    private final RefInjuryStatusRepository   injuryStatusRepo;
    private final RefBodyTypeRepository       bodyTypeRepo;

    private Map<String, List<LookupEntryDto>> cache;

    public LookupService(RefCrashTypeRepository crashTypeRepo,
                         RefHarmfulEventRepository harmfulEventRepo,
                         RefWeatherConditionRepository weatherConditionRepo,
                         RefSurfaceConditionRepository surfaceConditionRepo,
                         RefPersonTypeRepository personTypeRepo,
                         RefInjuryStatusRepository injuryStatusRepo,
                         RefBodyTypeRepository bodyTypeRepo) {
        this.crashTypeRepo         = crashTypeRepo;
        this.harmfulEventRepo      = harmfulEventRepo;
        this.weatherConditionRepo  = weatherConditionRepo;
        this.surfaceConditionRepo  = surfaceConditionRepo;
        this.personTypeRepo        = personTypeRepo;
        this.injuryStatusRepo      = injuryStatusRepo;
        this.bodyTypeRepo          = bodyTypeRepo;
    }

    @PostConstruct
    void init() {
        Map<String, List<LookupEntryDto>> map = new LinkedHashMap<>();

        map.put("crash-types", crashTypeRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, null, null, null, null))
                .toList());

        map.put("harmful-events", harmfulEventRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        e.getCategory(), null, null, null, null))
                .toList());

        map.put("weather-conditions", weatherConditionRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, null, null, null, null))
                .toList());

        map.put("surface-conditions", surfaceConditionRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, null, null, null, null))
                .toList());

        map.put("person-types", personTypeRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, null, e.isNonMotorist(), null, null))
                .toList());

        map.put("injury-statuses", injuryStatusRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, e.getKabcoLetter(), null, e.isRequiresFatalSection(), null))
                .toList());

        map.put("body-types", bodyTypeRepo.findAllByOrderByCodeAsc().stream()
                .map(e -> new LookupEntryDto(e.getCode(), e.getDescription(),
                        null, null, null, null, e.isRequiresLvSection()))
                .toList());

        this.cache = Collections.unmodifiableMap(map);
    }

    /** Returns all lookup types as a single map — use for bulk pre-loading. */
    public Map<String, List<LookupEntryDto>> getAll() {
        return cache;
    }

    /** Returns entries for a single lookup type by its URL-friendly name. */
    public List<LookupEntryDto> getByType(String type) {
        List<LookupEntryDto> entries = cache.get(type);
        if (entries == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "Unknown lookup type: " + type + ". Valid types: " + cache.keySet());
        }
        return entries;
    }
}
