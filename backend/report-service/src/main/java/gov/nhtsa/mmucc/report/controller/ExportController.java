package gov.nhtsa.mmucc.report.controller;

import gov.nhtsa.mmucc.report.dto.ExportFilter;
import gov.nhtsa.mmucc.report.service.CrashPdfService;
import gov.nhtsa.mmucc.report.service.ExportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;

@RestController
@RequestMapping("/reports")
@Tag(name = "Reports", description = "MMUCC crash data export and reporting")
@SecurityRequirement(name = "bearerAuth")
public class ExportController {

    private final ExportService exportService;
    private final CrashPdfService crashPdfService;

    public ExportController(ExportService exportService, CrashPdfService crashPdfService) {
        this.exportService = exportService;
        this.crashPdfService = crashPdfService;
    }

    @GetMapping("/crashes/export")
    @Operation(
        summary = "Export crash records as CSV",
        description = "Streams a CSV file containing all crashes matching the given filters. " +
                      "All filter parameters are optional. Results are ordered by date descending."
    )
    public void exportCrashes(ExportFilter filter, HttpServletResponse response) throws IOException {
        exportService.exportCsv(filter, response);
    }

    @GetMapping("/crashes/{id}/pdf")
    @Operation(summary = "Download a single crash record as a formatted PDF")
    public void downloadCrashPdf(@PathVariable Long id, HttpServletResponse response) throws IOException {
        byte[] pdf = crashPdfService.generatePdf(id);
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition", "attachment; filename=\"crash-" + id + ".pdf\"");
        response.setContentLength(pdf.length);
        response.getOutputStream().write(pdf);
    }
}
