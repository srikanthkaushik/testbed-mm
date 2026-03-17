package gov.nhtsa.mmucc.crash.validation;

import gov.nhtsa.mmucc.crash.dto.CrashRequest;
import gov.nhtsa.mmucc.crash.dto.FieldError;
import gov.nhtsa.mmucc.crash.dto.PersonRequest;
import gov.nhtsa.mmucc.crash.dto.VehicleRequest;
import gov.nhtsa.mmucc.crash.exception.ValidationException;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

/**
 * MMUCC v5 business-rule validator.
 * Throws {@link ValidationException} (→ HTTP 422) if any rules are violated.
 */
@Component
public class MmuccValidator {

    // personTypeCodes that indicate a non-motorist (P4)
    private static final Set<Integer> NON_MOTORIST_TYPES = Set.of(4, 5, 6, 7, 9);

    // unitTypeCodes that indicate a commercial motor vehicle (V2)
    private static final Set<Integer> CMV_UNIT_TYPES = Set.of(3, 4, 5, 6);

    // ── Crash rules ──────────────────────────────────────────────────────────

    public void validateCrash(CrashRequest r) {
        List<FieldError> errors = new ArrayList<>();

        // V-01: crash date must not be in the future
        if (r.crashDate() != null && r.crashDate().isAfter(LocalDate.now())) {
            errors.add(new FieldError("crashDate", "Crash date cannot be in the future"));
        }

        // V-02: work zone location required when work zone is related
        if (isYes(r.workZoneRelatedCode()) && r.workZoneLocationCode() == null) {
            errors.add(new FieldError("workZoneLocationCode",
                    "Work zone location is required when work zone related = Yes"));
        }

        // V-03: work zone type required when work zone is related
        if (isYes(r.workZoneRelatedCode()) && r.workZoneTypeCode() == null) {
            errors.add(new FieldError("workZoneTypeCode",
                    "Work zone type is required when work zone related = Yes"));
        }

        // V-04: numFatalities must be non-negative
        if (r.numFatalities() != null && r.numFatalities() < 0) {
            errors.add(new FieldError("numFatalities", "Number of fatalities cannot be negative"));
        }

        // V-05: numMotorVehicles must be at least 1 when provided
        if (r.numMotorVehicles() != null && r.numMotorVehicles() < 1) {
            errors.add(new FieldError("numMotorVehicles", "Number of motor vehicles must be at least 1"));
        }

        // V-06: fatal crash severity requires numFatalities > 0
        if (r.crashSeverityCode() != null && r.crashSeverityCode() == 1
                && r.numFatalities() != null && r.numFatalities() < 1) {
            errors.add(new FieldError("numFatalities",
                    "Fatal crash (severity = 1) must have at least 1 fatality"));
        }

        throwIfAny(errors);
    }

    // ── Person rules ─────────────────────────────────────────────────────────

    public void validatePerson(PersonRequest r) {
        List<FieldError> errors = new ArrayList<>();

        // V-07: alcohol test type required when test was given
        if (r.alcoholTestStatusCode() != null && r.alcoholTestStatusCode() == 1
                && r.alcoholTestTypeCode() == null) {
            errors.add(new FieldError("alcoholTestTypeCode",
                    "Alcohol test type is required when alcohol test status = Test Given"));
        }

        // V-08: drug test type required when test was given
        if (r.drugTestStatusCode() != null && r.drugTestStatusCode() == 1
                && r.drugTestTypeCode() == null) {
            errors.add(new FieldError("drugTestTypeCode",
                    "Drug test type is required when drug test status = Test Given"));
        }

        // V-09: age must be 0–120
        if (r.ageYears() != null && (r.ageYears() < 0 || r.ageYears() > 120)) {
            errors.add(new FieldError("ageYears", "Age must be between 0 and 120"));
        }

        // V-10: non-motorist should not be linked to a vehicle unit
        if (r.personTypeCode() != null && NON_MOTORIST_TYPES.contains(r.personTypeCode())
                && r.vehicleUnitNumber() != null) {
            errors.add(new FieldError("vehicleUnitNumber",
                    "Non-motorist (person type " + r.personTypeCode() + ") should not reference a vehicle unit"));
        }

        // V-11: seating position required for vehicle occupants
        if (r.personTypeCode() != null && !NON_MOTORIST_TYPES.contains(r.personTypeCode())
                && r.seatingRowCode() == null && r.seatingSeatCode() == null) {
            errors.add(new FieldError("seatingRowCode",
                    "Seating position (row and seat) is required for vehicle occupants"));
        }

        throwIfAny(errors);
    }

    // ── Vehicle rules ────────────────────────────────────────────────────────

    public void validateVehicle(VehicleRequest r) {
        List<FieldError> errors = new ArrayList<>();

        // V-12: speed limit must be 1–110 mph when provided
        if (r.speedLimitMph() != null && (r.speedLimitMph() < 1 || r.speedLimitMph() > 110)) {
            errors.add(new FieldError("speedLimitMph", "Speed limit must be between 1 and 110 mph"));
        }

        // V-13: CMV unit types should have trailing unit count
        if (r.unitTypeCode() != null && CMV_UNIT_TYPES.contains(r.unitTypeCode())
                && r.trailingUnitsCount() == null) {
            errors.add(new FieldError("trailingUnitsCount",
                    "Trailing unit count is required for commercial motor vehicles"));
        }

        // V-14: lane counts must be non-negative
        if (r.totalThroughLanes() != null && r.totalThroughLanes() < 0) {
            errors.add(new FieldError("totalThroughLanes", "Lane count cannot be negative"));
        }
        if (r.totalAuxiliaryLanes() != null && r.totalAuxiliaryLanes() < 0) {
            errors.add(new FieldError("totalAuxiliaryLanes", "Lane count cannot be negative"));
        }

        throwIfAny(errors);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private boolean isYes(Integer code) {
        return code != null && code == 1;
    }

    private void throwIfAny(List<FieldError> errors) {
        if (!errors.isEmpty()) throw new ValidationException(errors);
    }
}
