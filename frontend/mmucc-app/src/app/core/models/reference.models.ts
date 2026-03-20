/**
 * A single coded-value entry returned by the reference-service.
 * Extra fields are only present for the lookup types that carry them.
 */
export interface LookupEntry {
  code:                number;
  description:         string;
  /** Harmful event category (harmful-events only) */
  category?:           string;
  /** KABCO letter: K, A, B, C, O (injury-statuses only) */
  kabcoLetter?:        string;
  /** Whether the person type requires the Non-Motorist section (person-types only) */
  isNonMotorist?:      boolean;
  /** Whether the injury status requires the Fatal Section (injury-statuses only) */
  requiresFatalSection?: boolean;
  /** Whether the body type requires the Large Vehicle section (body-types only) */
  requiresLvSection?:  boolean;
}

/** Shape of the GET /lookups bulk response */
export interface AllLookups {
  'crash-types':         LookupEntry[];
  'harmful-events':      LookupEntry[];
  'weather-conditions':  LookupEntry[];
  'surface-conditions':  LookupEntry[];
  'person-types':        LookupEntry[];
  'injury-statuses':     LookupEntry[];
  'body-types':          LookupEntry[];
}
