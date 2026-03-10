package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "VEHICLE_TBL")
@Getter
@Setter
public class Vehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "VEH_VEHICLE_ID")
    private Long vehicleId;

    @Column(name = "VEH_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "VEH_VIN", length = 17)
    private String vin;

    @Column(name = "VEH_UNIT_TYPE_CODE")
    private Integer unitTypeCode;

    @Column(name = "VEH_UNIT_NUMBER")
    private Integer unitNumber;

    @Column(name = "VEH_REGISTRATION_STATE", length = 10)
    private String registrationState;

    @Column(name = "VEH_REGISTRATION_YEAR", columnDefinition = "YEAR")
    private Integer registrationYear;

    @Column(name = "VEH_LICENSE_PLATE", length = 20)
    private String licensePlate;

    @Column(name = "VEH_MAKE", length = 50)
    private String make;

    @Column(name = "VEH_MODEL_YEAR", columnDefinition = "YEAR")
    private Integer modelYear;

    @Column(name = "VEH_MODEL", length = 50)
    private String model;

    @Column(name = "VEH_BODY_TYPE_CODE")
    private Integer bodyTypeCode;

    @Column(name = "VEH_TRAILING_UNITS_COUNT")
    private Integer trailingUnitsCount;

    @Column(name = "VEH_VEHICLE_SIZE_CODE")
    private Integer vehicleSizeCode;

    @Column(name = "VEH_HM_PLACARD_FLG")
    private Integer hmPlacardFlg;

    @Column(name = "VEH_TOTAL_OCCUPANTS")
    private Integer totalOccupants;

    @Column(name = "VEH_SPECIAL_FUNCTION_CODE")
    private Integer specialFunctionCode;

    @Column(name = "VEH_EMERGENCY_USE_CODE")
    private Integer emergencyUseCode;

    @Column(name = "VEH_SPEED_LIMIT_MPH")
    private Integer speedLimitMph;

    @Column(name = "VEH_DIRECTION_OF_TRAVEL_CODE")
    private Integer directionOfTravelCode;

    @Column(name = "VEH_TRAFFICWAY_TRAVEL_DIR_CODE")
    private Integer trafficwayTravelDirCode;

    @Column(name = "VEH_TRAFFICWAY_DIVIDED_CODE")
    private Integer trafficwayDividedCode;

    @Column(name = "VEH_TRAFFICWAY_BARRIER_CODE")
    private Integer trafficwayBarrierCode;

    @Column(name = "VEH_TRAFFICWAY_HOV_HOT_CODE")
    private Integer trafficwayHovHotCode;

    @Column(name = "VEH_TRAFFICWAY_HOV_CRASH_FLG")
    private Integer trafficwayHovCrashFlg;

    @Column(name = "VEH_TOTAL_THROUGH_LANES")
    private Integer totalThroughLanes;

    @Column(name = "VEH_TOTAL_AUXILIARY_LANES")
    private Integer totalAuxiliaryLanes;

    @Column(name = "VEH_ROADWAY_ALIGNMENT_CODE")
    private Integer roadwayAlignmentCode;

    @Column(name = "VEH_ROADWAY_GRADE_CODE")
    private Integer roadwayGradeCode;

    @Column(name = "VEH_MANEUVER_CODE")
    private Integer maneuverCode;

    @Column(name = "VEH_DAMAGE_INITIAL_CONTACT")
    private Integer damageInitialContact;

    @Column(name = "VEH_DAMAGE_EXTENT_CODE")
    private Integer damageExtentCode;

    @Column(name = "VEH_MOST_HARMFUL_EVENT_CODE")
    private Integer mostHarmfulEventCode;

    @Column(name = "VEH_HIT_AND_RUN_CODE")
    private Integer hitAndRunCode;

    @Column(name = "VEH_TOWED_CODE")
    private Integer towedCode;

    @Column(name = "VEH_CONTRIBUTING_CIRC_CODE")
    private Integer contributingCircCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",
            column = @Column(name = "VEH_CREATED_BY", nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",
            column = @Column(name = "VEH_CREATED_DT", nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",
            column = @Column(name = "VEH_MODIFIED_BY", length = 100)),
        @AttributeOverride(name = "modifiedDt",
            column = @Column(name = "VEH_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode",
            column = @Column(name = "VEH_LAST_UPDATED_ACTIVITY_CODE", nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
