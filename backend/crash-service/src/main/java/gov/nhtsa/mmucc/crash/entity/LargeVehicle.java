package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "LARGE_VEHICLE_TBL")
@Getter
@Setter
public class LargeVehicle {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "LVH_ID")
    private Long id;

    @Column(name = "LVH_VEHICLE_ID", nullable = false)
    private Long vehicleId;

    @Column(name = "LVH_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "LVH_CMV_LICENSE_STATUS_CODE")
    private Integer cmvLicenseStatusCode;

    @Column(name = "LVH_CDL_COMPLIANCE_CODE")
    private Integer cdlComplianceCode;

    @Column(name = "LVH_TRAILER1_PLATE", length = 20)
    private String trailer1Plate;

    @Column(name = "LVH_TRAILER2_PLATE", length = 20)
    private String trailer2Plate;

    @Column(name = "LVH_TRAILER3_PLATE", length = 20)
    private String trailer3Plate;

    @Column(name = "LVH_TRAILER1_VIN", length = 17)
    private String trailer1Vin;

    @Column(name = "LVH_TRAILER2_VIN", length = 17)
    private String trailer2Vin;

    @Column(name = "LVH_TRAILER3_VIN", length = 17)
    private String trailer3Vin;

    @Column(name = "LVH_TRAILER1_MAKE", length = 50)
    private String trailer1Make;

    @Column(name = "LVH_TRAILER2_MAKE", length = 50)
    private String trailer2Make;

    @Column(name = "LVH_TRAILER3_MAKE", length = 50)
    private String trailer3Make;

    @Column(name = "LVH_TRAILER1_MODEL", length = 50)
    private String trailer1Model;

    @Column(name = "LVH_TRAILER2_MODEL", length = 50)
    private String trailer2Model;

    @Column(name = "LVH_TRAILER3_MODEL", length = 50)
    private String trailer3Model;

    @Column(name = "LVH_TRAILER1_YEAR")
    private Integer trailer1Year;

    @Column(name = "LVH_TRAILER2_YEAR")
    private Integer trailer2Year;

    @Column(name = "LVH_TRAILER3_YEAR")
    private Integer trailer3Year;

    @Column(name = "LVH_CARRIER_ID_TYPE_CODE")
    private Integer carrierIdTypeCode;

    @Column(name = "LVH_CARRIER_COUNTRY_STATE", length = 10)
    private String carrierCountryState;

    @Column(name = "LVH_CARRIER_ID_NUMBER", length = 20)
    private String carrierIdNumber;

    @Column(name = "LVH_CARRIER_NAME", length = 150)
    private String carrierName;

    @Column(name = "LVH_CARRIER_STREET1", length = 100)
    private String carrierStreet1;

    @Column(name = "LVH_CARRIER_STREET2", length = 100)
    private String carrierStreet2;

    @Column(name = "LVH_CARRIER_CITY", length = 100)
    private String carrierCity;

    @Column(name = "LVH_CARRIER_STATE", length = 10)
    private String carrierState;

    @Column(name = "LVH_CARRIER_ZIP", length = 20)
    private String carrierZip;

    @Column(name = "LVH_CARRIER_COUNTRY", length = 50)
    private String carrierCountry;

    @Column(name = "LVH_CARRIER_TYPE_CODE")
    private Integer carrierTypeCode;

    @Column(name = "LVH_VEHICLE_CONFIG_CODE")
    private Integer vehicleConfigCode;

    @Column(name = "LVH_VEHICLE_PERMITTED_CODE")
    private Integer vehiclePermittedCode;

    @Column(name = "LVH_CARGO_BODY_TYPE_CODE")
    private Integer cargoBodyTypeCode;

    @Column(name = "LVH_HM_ID", length = 10)
    private String hmId;

    @Column(name = "LVH_HM_CLASS", length = 5)
    private String hmClass;

    @Column(name = "LVH_HM_RELEASED_CODE")
    private Integer hmReleasedCode;

    @Column(name = "LVH_AXLES_TRACTOR")
    private Integer axlesTractor;

    @Column(name = "LVH_AXLES_TRAILER1")
    private Integer axlesTrailer1;

    @Column(name = "LVH_AXLES_TRAILER2")
    private Integer axlesTrailer2;

    @Column(name = "LVH_AXLES_TRAILER3")
    private Integer axlesTrailer3;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "LVH_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "LVH_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "LVH_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "LVH_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "LVH_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
