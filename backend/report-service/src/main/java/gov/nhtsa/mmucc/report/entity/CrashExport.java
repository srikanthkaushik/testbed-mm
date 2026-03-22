package gov.nhtsa.mmucc.report.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import org.hibernate.annotations.Immutable;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

/**
 * Read-only JPA projection of CRASH_TBL for export purposes.
 * No Flyway here — this service never modifies the schema.
 */
@Entity
@Table(name = "CRASH_TBL")
@Immutable
@Getter
public class CrashExport {

    @Id
    @Column(name = "CRS_CRASH_ID")
    private Long crashId;

    @Column(name = "CRS_CRASH_IDENTIFIER")
    private String crashIdentifier;

    @Column(name = "CRS_CRASH_DATE")
    private LocalDate crashDate;

    @Column(name = "CRS_CRASH_TIME")
    private LocalTime crashTime;

    @Column(name = "CRS_COUNTY_FIPS_CODE")
    private String countyFipsCode;

    @Column(name = "CRS_COUNTY_NAME")
    private String countyName;

    @Column(name = "CRS_CITY_PLACE_NAME")
    private String cityPlaceName;

    @Column(name = "CRS_ROUTE_ID")
    private String routeId;

    @Column(name = "CRS_ROUTE_TYPE_CODE")
    private Integer routeTypeCode;

    @Column(name = "CRS_CRASH_SEVERITY_CODE")
    private Integer crashSeverityCode;

    @Column(name = "CRS_CRASH_TYPE_CODE")
    private Integer crashTypeCode;

    @Column(name = "CRS_MANNER_COLLISION_CODE")
    private Integer mannerCollisionCode;

    @Column(name = "CRS_LIGHT_CONDITION_CODE")
    private Integer lightConditionCode;

    @Column(name = "CRS_FIRST_HARMFUL_EVENT_CODE")
    private Integer firstHarmfulEventCode;

    @Column(name = "CRS_LOC_FIRST_HARMFUL_EVENT")
    private Integer locFirstHarmfulEvent;

    @Column(name = "CRS_DAY_OF_WEEK_CODE")
    private Integer dayOfWeekCode;

    @Column(name = "CRS_NUM_MOTOR_VEHICLES")
    private Integer numMotorVehicles;

    @Column(name = "CRS_NUM_MOTORISTS")
    private Integer numMotorists;

    @Column(name = "CRS_NUM_NON_MOTORISTS")
    private Integer numNonMotorists;

    @Column(name = "CRS_NUM_NON_FATALLY_INJURED")
    private Integer numNonFatallyInjured;

    @Column(name = "CRS_NUM_FATALITIES")
    private Integer numFatalities;

    @Column(name = "CRS_ALCOHOL_INVOLVEMENT_CODE")
    private Integer alcoholInvolvementCode;

    @Column(name = "CRS_DRUG_INVOLVEMENT_CODE")
    private Integer drugInvolvementCode;

    @Column(name = "CRS_WORK_ZONE_RELATED_CODE")
    private Integer workZoneRelatedCode;

    @Column(name = "CRS_JUNCTION_INTERCHANGE_FLG")
    private Integer junctionInterchangeFlg;

    @Column(name = "CRS_SCHOOL_BUS_RELATED_CODE")
    private Integer schoolBusRelatedCode;

    @Column(name = "CRS_SOURCE_OF_INFO_CODE")
    private Integer sourceOfInfoCode;

    @Column(name = "CRS_LATITUDE", precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(name = "CRS_LONGITUDE", precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "CRS_CREATED_DT")
    private LocalDateTime createdDt;

    @Column(name = "CRS_MODIFIED_DT")
    private LocalDateTime modifiedDt;
}
