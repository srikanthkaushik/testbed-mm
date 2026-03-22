package gov.nhtsa.mmucc.report.dto;

import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

/**
 * Query parameters accepted by the CSV export endpoint.
 * All fields are optional — omitting them returns all crashes.
 */
public record ExportFilter(
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateFrom,
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dateTo,
        Integer severityCode,
        String countyCode
) {}
