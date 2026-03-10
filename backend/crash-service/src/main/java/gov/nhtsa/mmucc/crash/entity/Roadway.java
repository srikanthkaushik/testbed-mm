package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

@Entity
@Table(name = "ROADWAY_TBL")
@Getter
@Setter
public class Roadway {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "RWY_ROADWAY_ID")
    private Long roadwayId;

    @Column(name = "RWY_CRASH_ID", nullable = false, unique = true)
    private Long crashId;

    @Column(name = "RWY_BRIDGE_STRUCTURE_ID", length = 20)
    private String bridgeStructureId;

    @Column(name = "RWY_CURVE_RADIUS_FT", precision = 8, scale = 1)
    private BigDecimal curveRadiusFt;

    @Column(name = "RWY_CURVE_LENGTH_FT", precision = 8, scale = 1)
    private BigDecimal curveLengthFt;

    @Column(name = "RWY_CURVE_SUPERELEVATION_PCT", precision = 6, scale = 3)
    private BigDecimal curveSuperelevationPct;

    @Column(name = "RWY_GRADE_DIRECTION", length = 1)
    private String gradeDirection;

    @Column(name = "RWY_GRADE_PERCENT", precision = 5, scale = 2)
    private BigDecimal gradePercent;

    @Column(name = "RWY_NATIONAL_HWY_SYS_CODE")
    private Integer nationalHwySysCode;

    @Column(name = "RWY_FUNCTIONAL_CLASS_CODE")
    private Integer functionalClassCode;

    @Column(name = "RWY_AADT_YEAR", columnDefinition = "YEAR")
    private Integer aadtYear;

    @Column(name = "RWY_AADT_VALUE")
    private Integer aadtValue;

    @Column(name = "RWY_AADT_TRUCK_MEASURE", length = 20)
    private String aadtTruckMeasure;

    @Column(name = "RWY_AADT_MOTORCYCLE_MEASURE", length = 20)
    private String aadtMotorcycleMeasure;

    @Column(name = "RWY_LANE_WIDTH_FT", precision = 5, scale = 1)
    private BigDecimal laneWidthFt;

    @Column(name = "RWY_LEFT_SHOULDER_WIDTH_FT", precision = 5, scale = 1)
    private BigDecimal leftShoulderWidthFt;

    @Column(name = "RWY_RIGHT_SHOULDER_WIDTH_FT", precision = 5, scale = 1)
    private BigDecimal rightShoulderWidthFt;

    @Column(name = "RWY_MEDIAN_WIDTH_FT", precision = 6, scale = 1)
    private BigDecimal medianWidthFt;

    @Column(name = "RWY_ACCESS_CONTROL_CODE")
    private Integer accessControlCode;

    @Column(name = "RWY_RAILWAY_CROSSING_ID", length = 10)
    private String railwayCrossingId;

    @Column(name = "RWY_ROADWAY_LIGHTING_CODE")
    private Integer roadwayLightingCode;

    @Column(name = "RWY_PAVEMENT_EDGELINE_CODE")
    private Integer pavementEdgelineCode;

    @Column(name = "RWY_PAVEMENT_CENTERLINE_CODE")
    private Integer pavementCenterlineCode;

    @Column(name = "RWY_PAVEMENT_LANE_LINE_CODE")
    private Integer pavementLaneLineCode;

    @Column(name = "RWY_BICYCLE_FACILITY_CODE")
    private Integer bicycleFacilityCode;

    @Column(name = "RWY_BICYCLE_SIGNED_ROUTE_CODE")
    private Integer bicycleSignedRouteCode;

    @Column(name = "RWY_MAINLINE_LANES_COUNT")
    private Integer mainlineLanesCount;

    @Column(name = "RWY_CROSS_STREET_LANES_COUNT")
    private Integer crossStreetLanesCount;

    @Column(name = "RWY_ENTERING_VEHICLES_YEAR", columnDefinition = "YEAR")
    private Integer enteringVehiclesYear;

    @Column(name = "RWY_ENTERING_VEHICLES_AADT")
    private Integer enteringVehiclesAadt;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",
            column = @Column(name = "RWY_CREATED_BY", nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",
            column = @Column(name = "RWY_CREATED_DT", nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",
            column = @Column(name = "RWY_MODIFIED_BY", length = 100)),
        @AttributeOverride(name = "modifiedDt",
            column = @Column(name = "RWY_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode",
            column = @Column(name = "RWY_LAST_UPDATED_ACTIVITY_CODE", nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
