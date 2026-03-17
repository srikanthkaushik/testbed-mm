/**
 * Generic Spring Data Page wrapper.
 */
export interface Page<T> {
  content: T[];
  totalElements: number;
  totalPages: number;
  number: number;
  size: number;
  first: boolean;
  last: boolean;
}

/**
 * Lightweight crash record returned by GET /crashes (list endpoint).
 * Field names match CrashSummaryResponse from crash-service exactly.
 */
export interface CrashSummary {
  crashId: number;
  crashIdentifier: string | null;
  crashDate: string;            // "YYYY-MM-DD"
  crashTime: string | null;     // "HH:mm:ss"
  countyFipsCode: string | null;
  countyName: string | null;
  cityPlaceName: string | null;
  crashSeverityCode: number | null;
  numMotorVehicles: number;
  numFatalities: number;
  createdDt: string;
  modifiedDt: string | null;
}

/**
 * Filter/pagination parameters for the crash list query.
 */
export interface CrashFilter {
  dateFrom: string | null;
  dateTo: string | null;
  countyCode: number | null;
  minFatalities: number | null;
  page: number;
  size: number;
  sort: string;
}

/** Sequence number + code pair for multi-value child tables. */
export interface ChildCode {
  sequenceNum: number;
  code: number;
}

/** Traffic control device entry for vehicles. */
export interface TrafficControl {
  sequenceNum: number;
  trafficControlCode: number;
}

/** Vehicle record nested inside CrashDetail. */
export interface VehicleDetail {
  vehicleId: number;
  crashId: number;
  vin: string | null;
  unitTypeCode: number | null;
  unitNumber: number | null;
  registrationState: string | null;
  registrationYear: number | null;
  licensePlate: string | null;
  make: string | null;
  modelYear: number | null;
  model: string | null;
  bodyTypeCode: number | null;
  trailingUnitsCount: number | null;
  vehicleSizeCode: number | null;
  hmPlacardFlg: number | null;
  totalOccupants: number | null;
  specialFunctionCode: number | null;
  emergencyUseCode: number | null;
  speedLimitMph: number | null;
  directionOfTravelCode: number | null;
  trafficwayTravelDirCode: number | null;
  trafficwayDividedCode: number | null;
  trafficwayBarrierCode: number | null;
  trafficwayHovHotCode: number | null;
  trafficwayHovCrashFlg: number | null;
  totalThroughLanes: number | null;
  totalAuxiliaryLanes: number | null;
  roadwayAlignmentCode: number | null;
  roadwayGradeCode: number | null;
  maneuverCode: number | null;
  damageInitialContact: number | null;
  damageExtentCode: number | null;
  mostHarmfulEventCode: number | null;
  hitAndRunCode: number | null;
  towedCode: number | null;
  contributingCircCode: number | null;
  trafficControls: TrafficControl[];
  damageAreas: ChildCode[];
  sequenceEvents: ChildCode[];
  createdDt: string | null;
  modifiedDt: string | null;
}

/** Person drug test result entry (P23 SF3). */
export interface PersonDrugTest {
  sequenceNum: number;
  resultCode: number;
}

/** Person record nested inside CrashDetail (P1–P27). */
export interface PersonDetail {
  personId: number;
  crashId: number;
  vehicleId: number | null;
  // P1
  personName: string | null;
  // P2
  dobYear: number | null;
  dobMonth: number | null;
  dobDay: number | null;
  ageYears: number | null;
  // P3
  sexCode: number | null;
  // P4
  personTypeCode: number | null;
  incidentResponderCode: number | null;
  // P5
  injuryStatusCode: number | null;
  // P6
  vehicleUnitNumber: number | null;
  // P7
  seatingRowCode: number | null;
  seatingSeatCode: number | null;
  // P8
  restraintCode: number | null;
  restraintImproperFlg: number | null;
  // P9
  airbags: ChildCode[];
  // P10
  ejectionCode: number | null;
  // P11–P17 (driver license)
  dlJurisdictionType: number | null;
  dlJurisdictionCode: string | null;
  dlNumber: string | null;
  dlClassCode: number | null;
  dlIsCdlFlg: number | null;
  dlEndorsementCode: number | null;
  // P13
  speedingCode: number | null;
  // P14
  driverActions: ChildCode[];
  // P15
  violationCode1: string | null;
  violationCode2: string | null;
  // P16
  dlRestrictions: ChildCode[];
  dlAlcoholInterlockFlg: number | null;
  // P17
  dlStatusTypeCode: number | null;
  dlStatusCode: number | null;
  // P18
  distractedActionCode: number | null;
  distractedSourceCode: number | null;
  // P19
  conditionCode1: number | null;
  conditionCode2: number | null;
  // P20
  leSuspectsAlcohol: number | null;
  // P21
  alcoholTestStatusCode: number | null;
  alcoholTestTypeCode: number | null;
  alcoholBacResult: string | null;
  // P22
  leSuspectsDrug: number | null;
  // P23
  drugTestStatusCode: number | null;
  drugTestTypeCode: number | null;
  drugTestResults: PersonDrugTest[];
  // P24
  transportSourceCode: number | null;
  emsAgencyId: string | null;
  emsRunNumber: string | null;
  medicalFacility: string | null;
  // P25
  injuryAreaCode: number | null;
  // P26
  injuryDiagnosis: string | null;
  // P27
  injurySeverityCode: number | null;
  createdDt: string | null;
  modifiedDt: string | null;
}

/** Roadway record nested inside CrashDetail. */
export interface RoadwayDetail {
  roadwayId: number;
  crashId: number;
  bridgeStructureId: string | null;
  curveRadiusFt: number | null;
  curveLengthFt: number | null;
  curveSuperelevationPct: number | null;
  gradeDirection: string | null;
  gradePercent: number | null;
  nationalHwySysCode: number | null;
  functionalClassCode: number | null;
  aadtYear: number | null;
  aadtValue: number | null;
  aadtTruckMeasure: string | null;
  aadtMotorcycleMeasure: string | null;
  laneWidthFt: number | null;
  leftShoulderWidthFt: number | null;
  rightShoulderWidthFt: number | null;
  medianWidthFt: number | null;
  accessControlCode: number | null;
  railwayCrossingId: string | null;
  roadwayLightingCode: number | null;
  pavementEdgelineCode: number | null;
  pavementCenterlineCode: number | null;
  pavementLaneLineCode: number | null;
  bicycleFacilityCode: number | null;
  bicycleSignedRouteCode: number | null;
  mainlineLanesCount: number | null;
  crossStreetLanesCount: number | null;
  enteringVehiclesYear: number | null;
  enteringVehiclesAadt: number | null;
  createdDt: string | null;
  modifiedDt: string | null;
}

/** One entry in the crash audit log returned by GET /crashes/{id}/audit. */
export interface AuditLogEntry {
  auditId:    number;
  actionCode: string;          // CREATE | UPDATE | DELETE
  tableName:  string;
  recordId:   number | null;
  username:   string;
  timestamp:  string;          // ISO-8601 datetime
  oldValue:   string | null;   // JSON snapshot before change
  newValue:   string | null;   // JSON snapshot after change
}

/**
 * Full crash aggregate returned by GET /crashes/{id}.
 * Field names match CrashDetailResponse from crash-service exactly.
 */
export interface CrashDetail {
  crashId: number;
  crashIdentifier: string | null;
  crashTypeCode: number | null;
  firstHarmfulEventCode: number | null;
  crashDate: string;
  crashTime: string | null;
  countyFipsCode: string | null;
  countyName: string | null;
  cityPlaceCode: string | null;
  cityPlaceName: string | null;
  routeId: string | null;
  routeTypeCode: number | null;
  routeDirectionCode: number | null;
  distanceFromRefMiles: number | null;
  refPointDirectionCode: number | null;
  latitude: number | null;
  longitude: number | null;
  locFirstHarmfulEvent: number | null;
  mannerCollisionCode: number | null;
  sourceOfInfoCode: number | null;
  lightConditionCode: number | null;
  junctionInterchangeFlg: number | null;
  junctionLocationCode: number | null;
  intersectionApproaches: number | null;
  intersectionGeometryCode: number | null;
  intersectionTrafficCtl: number | null;
  schoolBusRelatedCode: number | null;
  workZoneRelatedCode: number | null;
  workZoneLocationCode: number | null;
  workZoneTypeCode: number | null;
  workZoneWorkersCode: number | null;
  workZoneLawEnfCode: number | null;
  crashSeverityCode: number | null;
  numMotorVehicles: number | null;
  numMotorists: number | null;
  numNonMotorists: number | null;
  numNonFatallyInjured: number | null;
  numFatalities: number | null;
  alcoholInvolvementCode: number | null;
  drugInvolvementCode: number | null;
  dayOfWeekCode: number | null;
  weatherConditions: ChildCode[];
  surfaceConditions: ChildCode[];
  contributingCircumstances: ChildCode[];
  roadway: RoadwayDetail | null;
  vehicles: VehicleDetail[];
  persons: PersonDetail[];
  createdBy: string | null;
  createdDt: string | null;
  modifiedBy: string | null;
  modifiedDt: string | null;
}
