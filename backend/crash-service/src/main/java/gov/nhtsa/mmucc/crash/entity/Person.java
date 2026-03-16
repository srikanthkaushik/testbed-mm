package gov.nhtsa.mmucc.crash.entity;

import gov.nhtsa.mmucc.common.audit.AuditFields;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "PERSON_TBL")
@Getter
@Setter
public class Person {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PRS_PERSON_ID")
    private Long personId;

    @Column(name = "PRS_CRASH_ID", nullable = false)
    private Long crashId;

    @Column(name = "PRS_VEHICLE_ID")
    private Long vehicleId;

    @Column(name = "PRS_PERSON_NAME", length = 150)
    private String personName;

    @Column(name = "PRS_DOB_YEAR")
    private Integer dobYear;

    @Column(name = "PRS_DOB_MONTH")
    private Integer dobMonth;

    @Column(name = "PRS_DOB_DAY")
    private Integer dobDay;

    @Column(name = "PRS_AGE_YEARS")
    private Integer ageYears;

    @Column(name = "PRS_SEX_CODE")
    private Integer sexCode;

    @Column(name = "PRS_PERSON_TYPE_CODE")
    private Integer personTypeCode;

    @Column(name = "PRS_INCIDENT_RESPONDER_CODE")
    private Integer incidentResponderCode;

    @Column(name = "PRS_INJURY_STATUS_CODE")
    private Integer injuryStatusCode;

    @Column(name = "PRS_VEHICLE_UNIT_NUMBER")
    private Integer vehicleUnitNumber;

    @Column(name = "PRS_SEATING_ROW_CODE")
    private Integer seatingRowCode;

    @Column(name = "PRS_SEATING_SEAT_CODE")
    private Integer seatingSeatCode;

    @Column(name = "PRS_RESTRAINT_CODE")
    private Integer restraintCode;

    @Column(name = "PRS_RESTRAINT_IMPROPER_FLG")
    private Integer restraintImproperFlg;

    @Column(name = "PRS_EJECTION_CODE")
    private Integer ejectionCode;

    @Column(name = "PRS_DL_JURISDICTION_TYPE")
    private Integer dlJurisdictionType;

    @Column(name = "PRS_DL_JURISDICTION_CODE", length = 10)
    private String dlJurisdictionCode;

    @Column(name = "PRS_DL_NUMBER", length = 30)
    private String dlNumber;

    @Column(name = "PRS_DL_CLASS_CODE")
    private Integer dlClassCode;

    @Column(name = "PRS_DL_IS_CDL_FLG")
    private Integer dlIsCdlFlg;

    @Column(name = "PRS_DL_ENDORSEMENT_CODE")
    private Integer dlEndorsementCode;

    @Column(name = "PRS_SPEEDING_CODE")
    private Integer speedingCode;

    @Column(name = "PRS_VIOLATION_CODE_1", length = 20)
    private String violationCode1;

    @Column(name = "PRS_VIOLATION_CODE_2", length = 20)
    private String violationCode2;

    @Column(name = "PRS_DL_ALCOHOL_INTERLOCK_FLG")
    private Integer dlAlcoholInterlockFlg;

    @Column(name = "PRS_DL_STATUS_TYPE_CODE")
    private Integer dlStatusTypeCode;

    @Column(name = "PRS_DL_STATUS_CODE")
    private Integer dlStatusCode;

    @Column(name = "PRS_DISTRACTED_ACTION_CODE")
    private Integer distractedActionCode;

    @Column(name = "PRS_DISTRACTED_SOURCE_CODE")
    private Integer distractedSourceCode;

    @Column(name = "PRS_CONDITION_CODE_1")
    private Integer conditionCode1;

    @Column(name = "PRS_CONDITION_CODE_2")
    private Integer conditionCode2;

    @Column(name = "PRS_LE_SUSPECTS_ALCOHOL")
    private Integer leSuspectsAlcohol;

    @Column(name = "PRS_ALCOHOL_TEST_STATUS_CODE")
    private Integer alcoholTestStatusCode;

    @Column(name = "PRS_ALCOHOL_TEST_TYPE_CODE")
    private Integer alcoholTestTypeCode;

    @Column(name = "PRS_ALCOHOL_BAC_RESULT", length = 10)
    private String alcoholBacResult;

    @Column(name = "PRS_LE_SUSPECTS_DRUG")
    private Integer leSuspectsDrug;

    @Column(name = "PRS_DRUG_TEST_STATUS_CODE")
    private Integer drugTestStatusCode;

    @Column(name = "PRS_DRUG_TEST_TYPE_CODE")
    private Integer drugTestTypeCode;

    @Column(name = "PRS_TRANSPORT_SOURCE_CODE")
    private Integer transportSourceCode;

    @Column(name = "PRS_EMS_AGENCY_ID", length = 50)
    private String emsAgencyId;

    @Column(name = "PRS_EMS_RUN_NUMBER", length = 50)
    private String emsRunNumber;

    @Column(name = "PRS_MEDICAL_FACILITY", length = 100)
    private String medicalFacility;

    @Column(name = "PRS_INJURY_AREA_CODE")
    private Integer injuryAreaCode;

    @Column(name = "PRS_INJURY_DIAGNOSIS", columnDefinition = "TEXT")
    private String injuryDiagnosis;

    @Column(name = "PRS_INJURY_SEVERITY_CODE")
    private Integer injurySeverityCode;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "createdBy",               column = @Column(name = "PRS_CREATED_BY",                   nullable = false, length = 100)),
        @AttributeOverride(name = "createdDt",               column = @Column(name = "PRS_CREATED_DT",                   nullable = false, updatable = false)),
        @AttributeOverride(name = "modifiedBy",              column = @Column(name = "PRS_MODIFIED_BY",                  length = 100)),
        @AttributeOverride(name = "modifiedDt",              column = @Column(name = "PRS_MODIFIED_DT")),
        @AttributeOverride(name = "lastUpdatedActivityCode", column = @Column(name = "PRS_LAST_UPDATED_ACTIVITY_CODE",   nullable = false, length = 20))
    })
    private AuditFields audit = new AuditFields();
}
