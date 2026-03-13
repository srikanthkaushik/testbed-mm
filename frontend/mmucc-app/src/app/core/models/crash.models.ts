/**
 * Generic Spring Data Page wrapper.
 * Mirrors the structure returned by Spring Boot's Pageable endpoints.
 */
export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;   // current page, 0-based
  size: number;
  first: boolean;
  last: boolean;
}

/**
 * Lightweight crash record returned by GET /crashes (list endpoint).
 * Mirrors CrashSummaryResponse DTO from the crash-service.
 */
export interface CrashSummary {
  crashId: number;
  caseNumber: string | null;
  crashDate: string;            // ISO date, e.g. "2024-03-15"
  crashTime: string | null;     // "HH:mm" 24-hour
  countyCode: number | null;
  countyName: string | null;
  cityName: string | null;
  crashTypeCode: number | null;
  crashTypeName: string | null;
  totalFatalities: number;
  totalInjuries: number;
  vehicleCount: number;
  personCount: number;
  mannerOfCollisionCode: number | null;
  mannerOfCollisionName: string | null;
  createdBy: string;
  createdDt: string;            // ISO datetime string
}

/**
 * Filter/pagination parameters for the crash list query.
 * Null fields are omitted when building HttpParams.
 */
export interface CrashFilter {
  dateFrom: string | null;      // ISO date
  dateTo: string | null;        // ISO date
  countyCode: number | null;
  minFatalities: number | null;
  page: number;                 // 0-based
  size: number;
  sort: string;                 // e.g. "crashDate,desc"
}
