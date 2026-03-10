package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "CRASH_TBL")
@Getter
@Setter
public class Crash {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CRS_CRASH_ID")
    private Long crashId;

    @Column(name = "CRS_CRASH_IDENTIFIER", length = 50)
    private String crashIdentifier;

    @Column(name = "CRS_CRASH_TYPE_CODE")
    private Integer crashTypeCode;

    @Column(name = "CRS_FIRST_HARMFUL_EVENT_CODE")
    private Integer firstHarmfulEventCode;

    @Column(name = "CRS_CRASH_DATE")
    private LocalDate crashDate;

    @Column(name = "CRS_CRASH_TIME")
    private LocalTime crashTime;

    @Column(name = "CRS_COUNTY_FIPS_CODE", length = 10)
    private String countyFipsCode;

    @Column(name = "CRS_COUNTY_NAME", length = 100)
    private String countyName;

    @Column(name = "CRS_CITY_PLACE_CODE", length = 10)
    private String cityPlaceCode;

    @Column(name = "CRS_CITY_PLACE_NAME", length = 100)
    private String cityPlaceName;

    @Column(name = "CRS_ROUTE_ID", length = 50)
    private String routeId;

    @Column(name = "CRS_ROUTE_TYPE_CODE")
    private Integer routeTypeCode;

    @Column(name = "CRS_ROUTE_DIRECTION_CODE")
    private Integer routeDirectionCode;

    @Column(name = "CRS_DISTANCE_FROM_REF_MILES", precision = 8, scale = 3)
    private BigDecimal distanceFromRefMiles;

    @Column(name = "CRS_REF_POINT_DIRECTION_CODE")
    private Integer refPointDirectionCode;

    @Column(name = "CRS_LATITUDE", precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(name = "CRS_LONGITUDE", precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "CRS_LOC_FIRST_HARMFUL_EVENT")
    private Integer locFirstHarmfulEvent;

    @Column(name = "CRS_MANNER_COLLISION_CODE")
    private Integer mannerCollisionCode;

    @Column(name = "CRS_SOURCE_OF_INFO_CODE")
    private Integer sourceOfInfoCode;

    @Column(name = "CRS_LIGHT_CONDITION_CODE")
    private Integer lightConditionCode;

    @Column(name = "CRS_JUNCTION_INTERCHANGE_FLG")
    private Integer junctionInterchangeFlg;

    @Column(name = "CRS_JUNCTION_LOCATION_CODE")
    private Integer junctionLocationCode;

    @Column(name = "CRS_INTERSECTION_APPROACHES")
    private Integer intersectionApproaches;

    @Column(name = "CRS_INTERSECTION_GEOMETRY_CODE")
    private Integer intersectionGeometryCode;

    @Column(name = "CRS_INTERSECTION_TRAFFIC_CTL")
    private Integer intersectionTrafficCtl;

    @Column(name = "CRS_SCHOOL_BUS_RELATED_CODE")
    private Integer schoolBusRelatedCode;

    @Column(name = "CRS_WORK_ZONE_RELATED_CODE")
    private Integer workZoneRelatedCode;

    @Column(name = "CRS_WORK_ZONE_LOCATION_CODE")
    private Integer workZoneLocationCode;

    @Column(name = "CRS_WORK_ZONE_TYPE_CODE")
    private Integer workZoneTypeCode;

    @Column(name = "CRS_WORK_ZONE_WORKERS_CODE")
    private Integer workZoneWorkersCode;

    @Column(name = "CRS_WORK_ZONE_LAW_ENF_CODE")
    private Integer workZoneLawEnfCode;

    @Column(name = "CRS_CRASH_SEVERITY_CODE")
    private Integer crashSeverityCode;

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

    @Column(name = "CRS_DAY_OF_WEEK_CODE")
    private Integer dayOfWeekCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",
            column = @Column(name = "CRS_CREATED_BY", nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",
            column = @Column(name = "CRS_CREATED_DT", nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",
            column = @Column(name = "CRS_MODIFIED_BY", length = 100)),
        @AttributeOverride(name = "modifiedDt",
            column = @Column(name = "CRS_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode",
            column = @Column(name = "CRS_LAST_UPDATED_ACTIVITY_CODE", nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
