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
  createdBy: string | null;
  createdDt: string | null;
  modifiedBy: string | null;
  modifiedDt: string | null;
}
