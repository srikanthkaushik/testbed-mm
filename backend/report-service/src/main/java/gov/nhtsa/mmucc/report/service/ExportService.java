package gov.nhtsa.mmucc.report.service;

import gov.nhtsa.mmucc.report.dto.ExportFilter;
import gov.nhtsa.mmucc.report.entity.CrashExport;
import gov.nhtsa.mmucc.report.repository.CrashExportRepository;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

@Service
public class ExportService {

    private static final String[] CSV_HEADERS = {
        "Crash ID", "Case Number", "Date", "Time", "Day of Week",
        "County FIPS", "County", "City/Place",
        "Route ID", "Route Type Code",
        "Severity Code", "Crash Type Code", "Manner of Collision Code",
        "Light Condition Code", "First Harmful Event Code", "Location First Harmful Event",
        "Junction Related", "School Bus Related", "Work Zone Related",
        "Alcohol Involvement", "Drug Involvement",
        "Motor Vehicles", "Motorists", "Non-Motorists",
        "Non-Fatal Injured", "Fatalities",
        "Source of Info Code",
        "Latitude", "Longitude",
        "Created", "Modified"
    };

    private final CrashExportRepository repository;

    public ExportService(CrashExportRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    public void exportCsv(ExportFilter filter, HttpServletResponse response) throws IOException {
        String filename = "crashes-export-" + LocalDate.now() + ".csv";
        response.setContentType("text/csv;charset=UTF-8");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        List<CrashExport> crashes = repository.findForExport(
                filter.dateFrom(), filter.dateTo(), filter.severityCode(), filter.countyCode());

        PrintWriter writer = response.getWriter();
        writer.println(String.join(",", CSV_HEADERS));

        for (CrashExport c : crashes) {
            writer.println(buildRow(c));
        }
        writer.flush();
    }

    private String buildRow(CrashExport c) {
        return String.join(",",
                csv(c.getCrashId()),
                csv(c.getCrashIdentifier()),
                csv(c.getCrashDate()),
                csv(c.getCrashTime() != null ? c.getCrashTime().toString().substring(0, 5) : null),
                csv(c.getDayOfWeekCode()),
                csv(c.getCountyFipsCode()),
                csv(c.getCountyName()),
                csv(c.getCityPlaceName()),
                csv(c.getRouteId()),
                csv(c.getRouteTypeCode()),
                csv(c.getCrashSeverityCode()),
                csv(c.getCrashTypeCode()),
                csv(c.getMannerCollisionCode()),
                csv(c.getLightConditionCode()),
                csv(c.getFirstHarmfulEventCode()),
                csv(c.getLocFirstHarmfulEvent()),
                csv(c.getJunctionInterchangeFlg()),
                csv(c.getSchoolBusRelatedCode()),
                csv(c.getWorkZoneRelatedCode()),
                csv(c.getAlcoholInvolvementCode()),
                csv(c.getDrugInvolvementCode()),
                csv(c.getNumMotorVehicles()),
                csv(c.getNumMotorists()),
                csv(c.getNumNonMotorists()),
                csv(c.getNumNonFatallyInjured()),
                csv(c.getNumFatalities()),
                csv(c.getSourceOfInfoCode()),
                csv(c.getLatitude()),
                csv(c.getLongitude()),
                csv(c.getCreatedDt()),
                csv(c.getModifiedDt())
        );
    }

    /** Safely converts any value to a CSV cell, quoting strings that contain commas or quotes. */
    private String csv(Object v) {
        if (v == null) return "";
        String s = v.toString();
        if (s.contains(",") || s.contains("\"") || s.contains("\n") || s.contains("\r")) {
            return "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }
}
