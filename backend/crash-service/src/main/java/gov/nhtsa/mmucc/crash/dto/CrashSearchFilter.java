package gov.nhtsa.mmucc.crash.dto;

import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/** Query parameters for GET /crashes */
public record CrashSearchFilter(
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
        Integer severity,
        String county,
        int page,
        int size
) {
    public CrashSearchFilter {
        if (size <= 0 || size > 200) size = 20;
        if (page < 0) page = 0;
    }
}
