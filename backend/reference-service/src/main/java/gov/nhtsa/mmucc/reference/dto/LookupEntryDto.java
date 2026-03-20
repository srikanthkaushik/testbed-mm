package gov.nhtsa.mmucc.reference.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

/**
 * Generic response DTO for all MMUCC reference lookup entries.
 * Extra fields (category, kabcoLetter, etc.) are only populated for the
 * lookup types that carry them; all others are omitted from the JSON response.
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record LookupEntryDto(
        int    code,
        String description,
        /** Harmful event category: NON_HARMFUL, NON_COLLISION_HARMFUL, COLLISION_PERSON_MV, COLLISION_FIXED */
        String  category,
        /** KABCO injury severity letter (injury-statuses only): K, A, B, C, O */
        String  kabcoLetter,
        /** Whether person type triggers the Non-Motorist section (person-types only) */
        Boolean isNonMotorist,
        /** Whether injury status requires the Fatal Section (injury-statuses only) */
        Boolean requiresFatalSection,
        /** Whether body type requires the Large Vehicle section (body-types only) */
        Boolean requiresLvSection
) {}
