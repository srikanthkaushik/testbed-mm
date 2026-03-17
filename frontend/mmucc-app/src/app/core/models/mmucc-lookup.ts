/**
 * MMUCC v5 coded-value lookup maps.
 * Each map key is the numeric code; each value is the human-readable description.
 * Used by crash-detail to render "N — Description" labels.
 */

// C2 SF1 – Crash Type
export const CRASH_TYPE: Record<number, string> = {
  1:  'Single Vehicle',
  2:  'Two Vehicle – Same Direction',
  3:  'Two Vehicle – Opposite Direction',
  4:  'Two Vehicle – Intersecting Direction',
  5:  'Two Vehicle – Other',
  6:  'Three or More Vehicle',
  99: 'Unknown',
};

// C7 / V20 / V21 – First Harmful Event / Sequence of Events
export const HARMFUL_EVENT: Record<number, string> = {
  1:  'Cross Centerline',
  2:  'Cross Median',
  3:  'End Departure',
  4:  'Downhill Runaway',
  5:  'Equipment Failure',
  6:  'Ran Off Roadway Left',
  7:  'Ran Off Roadway Right',
  8:  'Reentering Roadway',
  9:  'Separation of Units',
  10: 'Other Non-Harmful Event',
  11: 'Cargo/Equipment Loss or Shift',
  12: 'Fell/Jumped From Motor Vehicle',
  13: 'Fire/Explosion',
  14: 'Immersion, Full or Partial',
  15: 'Jackknife',
  16: 'Other Non-Collision Harmful Event',
  17: 'Overturn/Rollover',
  18: 'Thrown or Falling Object',
  19: 'Animal (live)',
  20: 'Motor Vehicle in Transport',
  21: 'Other Non-Fixed Object',
  22: 'Other Non-Motorist',
  23: 'Parked Motor Vehicle',
  24: 'Pedalcycle',
  25: 'Pedestrian',
  26: 'Railway Vehicle (train, engine)',
  27: 'Strikes Object at Rest from MV in Transport',
  28: 'Struck by Falling/Shifting Cargo from MV',
  29: 'Work Zone/Maintenance Equipment',
  30: 'Bridge Overhead Structure',
  31: 'Bridge Pier or Support',
  32: 'Bridge Rail',
  33: 'Cable Barrier',
  34: 'Concrete Traffic Barrier',
  35: 'Culvert',
  36: 'Curb',
  37: 'Ditch',
  38: 'Embankment',
  39: 'Fence',
  40: 'Guardrail End Terminal',
  41: 'Guardrail Face',
  42: 'Impact Attenuator/Crash Cushion',
  43: 'Mailbox',
  44: 'Other Fixed Object (wall, building, tunnel)',
  45: 'Other Post, Pole, or Support',
  46: 'Other Traffic Barrier',
  47: 'Traffic Sign Support',
  48: 'Traffic Signal Support',
  49: 'Tree (standing)',
  50: 'Utility Pole/Light Support',
  51: 'Unknown Fixed Object',
};

// C9 – Manner of Collision
export const MANNER_COLLISION: Record<number, string> = {
  1:  'Not Collision Between Two Motor Vehicles in Transport',
  2:  'Front-to-Rear',
  3:  'Front-to-Front',
  6:  'Angle',
  7:  'Sideswipe – Same Direction',
  8:  'Sideswipe – Opposite Direction',
  9:  'Rear-to-Side',
  10: 'Rear-to-Rear',
  98: 'Other',
  99: 'Unknown',
};

// C11 – Weather Condition
export const WEATHER_CONDITION: Record<number, string> = {
  1:  'Clear',
  2:  'Cloudy',
  3:  'Rain',
  4:  'Snow',
  5:  'Fog, Smog, Smoke',
  6:  'Sleet, Hail',
  7:  'Blowing Snow',
  8:  'Blowing Sand, Soil, Dirt',
  9:  'Severe Crosswinds',
  10: 'Freezing Rain or Drizzle',
  98: 'Other',
  99: 'Unknown',
};

// C12 – Light Condition
export const LIGHT_CONDITION: Record<number, string> = {
  1:  'Daylight',
  2:  'Dark – Not Lighted',
  3:  'Dark – Lighted',
  4:  'Dawn',
  5:  'Dusk',
  6:  'Dark – Unknown Lighting',
  7:  'Other',
  99: 'Unknown',
};

// C13 – Roadway Surface Condition
export const SURFACE_CONDITION: Record<number, string> = {
  1:  'Dry',
  2:  'Wet',
  3:  'Snow or Slush',
  4:  'Ice',
  5:  'Sand, Mud, Dirt, Oil, Gravel',
  6:  'Water (Standing or Moving)',
  7:  'Oil',
  98: 'Other',
  99: 'Unknown',
};

// C14 – Junction/Interchange Type
export const JUNCTION_TYPE: Record<number, string> = {
  1:  'Non-Junction',
  2:  'Intersection',
  3:  'Intersection-Related',
  4:  'Driveway/Alley Access',
  5:  'Entrance/Exit Ramp Related',
  6:  'Railway Grade Crossing',
  7:  'Crossover-Related',
  8:  'Shared-Use Path Crossing',
  9:  'Acceleration/Deceleration Lane',
  10: 'Through Roadway',
  11: 'Other Location',
  99: 'Unknown',
};

// C15 – Intersection Geometry
export const INTERSECTION_GEOMETRY: Record<number, string> = {
  1: 'T-Intersection',
  2: 'Y-Intersection',
  3: 'Four-Way Intersection',
  4: 'Five-Point or More',
  5: 'Traffic Circle/Roundabout',
  6: 'Ramp',
  7: 'Other',
  9: 'Unknown',
};

// C15 – Intersection Traffic Control
export const INTERSECTION_TRAFFIC_CTL: Record<number, string> = {
  1: 'No Controls',
  2: 'Traffic Signal',
  3: 'Stop Sign',
  4: 'Yield Sign',
  5: 'Flashing Signal',
  6: 'Officer',
  7: 'Other',
  9: 'Unknown',
};

// C17 – Alcohol Involvement
export const INVOLVEMENT: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  8: 'Not Applicable',
  9: 'Unknown',
};

// C25 / C26 – Yes/No/Unknown
export const YES_NO: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

// C27 – Work Zone Location
export const WORK_ZONE_LOCATION: Record<number, string> = {
  1: 'Before Work Zone',
  2: 'Advance Warning Area',
  3: 'Transition Area',
  4: 'Activity Area',
  5: 'Termination Area',
  6: 'After Work Zone',
  9: 'Unknown',
};

// C28 – Work Zone Type
export const WORK_ZONE_TYPE: Record<number, string> = {
  1: 'Lane Closure',
  2: 'Lane Shift/Crossover',
  3: 'Work on Shoulder or Median',
  4: 'Intermittent or Moving Work Zone',
  5: 'Other',
  9: 'Unknown',
};

// C8 – Location of First Harmful Event
export const LOC_FIRST_HARMFUL_EVENT: Record<number, string> = {
  1:  'On Roadway',
  2:  'On Shoulder',
  3:  'On Median',
  4:  'On Roadside',
  5:  'Outside Trafficway',
  6:  'Off Roadway – Location Unknown',
  7:  'In Parking Lane/Zone',
  8:  'Gore',
  9:  'Separator',
  10: 'Continuous Left Turn Lane',
  11: 'Bicycle Lane',
  12: 'On Sidewalk',
  98: 'Other',
  99: 'Unknown',
};

// V1 – Unit Type
export const UNIT_TYPE: Record<number, string> = {
  1: 'Motor Vehicle in Transport',
  2: 'Parked Motor Vehicle',
  3: 'Working Motor Vehicle',
  4: 'Non-Motor Vehicle Transport Device',
  5: 'Person on Personal Conveyance',
  9: 'Unknown',
};

// V8 SF1 – Motor Vehicle Body Type
export const BODY_TYPE: Record<number, string> = {
  1:  'All-Terrain Vehicle/ATC (ATV/ATC)',
  2:  'Golf Cart',
  3:  'Snowmobile',
  4:  'Low Speed Vehicle',
  5:  'Moped or Motorized Bicycle',
  6:  'Recreational Off-Highway Vehicle (ROV)',
  7:  '2-Wheeled Motorcycle',
  8:  '3-Wheeled Motorcycle',
  9:  'Autocycle',
  10: 'Passenger Car',
  11: 'Passenger Van (fewer than 9 seats)',
  12: '(Sport) Utility Vehicle',
  13: 'Pickup',
  14: 'Cargo Van',
  15: 'Construction Equipment (backhoe, bulldozer, etc.)',
  16: 'Farm Equipment (tractor, combine harvester, etc.)',
  17: 'Single-Unit Truck',
  18: 'Truck Tractor',
  19: 'Motor Home',
  20: '9- or 12-Passenger Van',
  21: '15-Passenger Van',
  22: 'Large Limo',
  23: 'Mini-bus',
  24: 'School Bus',
  25: 'Transit Bus',
  26: 'Motorcoach',
  27: 'Other Bus Type',
  28: 'Other Trucks',
  98: 'Other',
};

// V7 – Traffic Control Device
export const TRAFFIC_CONTROL: Record<number, string> = {
  1:  'No Controls',
  2:  'Officer',
  3:  'Flagperson',
  4:  'Traffic Signal',
  5:  'Flashing Traffic Signal',
  6:  'Stop Sign',
  7:  'Yield Sign',
  8:  'Warning Sign',
  9:  'Railway Crossing Device – Active',
  10: 'Railway Crossing Device – Passive',
  11: 'School Zone Sign/Equipment',
  12: 'Crosswalk Marking',
  13: 'Center Line / No Passing Zone Marking',
  14: 'Marked Lanes',
  15: 'Speed Reduction Zone',
  16: 'Other Control',
  99: 'Unknown',
};

// V13 – Direction of Travel
export const DIRECTION_OF_TRAVEL: Record<number, string> = {
  1: 'North',
  2: 'Northeast',
  3: 'East',
  4: 'Southeast',
  5: 'South',
  6: 'Southwest',
  7: 'West',
  8: 'Northwest',
  9: 'Unknown',
};

// V14 – Trafficway Description (Travel Direction)
export const TRAFFICWAY_TRAVEL_DIR: Record<number, string> = {
  1: 'One-Way Trafficway',
  2: 'Two-Way, Not Divided',
  3: 'Two-Way, Divided, Unprotected Median',
  4: 'Two-Way, Divided, Positive Median Barrier',
  5: 'Two-Way, Unknown if Divided',
  9: 'Unknown',
};

// V15 – Trafficway Divided
export const TRAFFICWAY_DIVIDED: Record<number, string> = {
  1: 'Not Divided',
  2: 'Divided, With Non-Mountable Median (Barrier)',
  3: 'Divided, With Mountable Median (Curbing)',
  9: 'Unknown',
};

// V16 – Roadway Alignment
export const ROADWAY_ALIGNMENT: Record<number, string> = {
  1: 'Straight',
  2: 'Curve Left',
  3: 'Curve Right',
  9: 'Unknown',
};

// V17 – Roadway Grade
export const ROADWAY_GRADE: Record<number, string> = {
  1: 'Level',
  2: 'Grade',
  3: 'Hillcrest',
  4: 'Sag (Bottom)',
  9: 'Unknown',
};

// V18 – Pre-Crash Vehicle Maneuver
export const MANEUVER: Record<number, string> = {
  1:  'Going Straight',
  2:  'Turning Left',
  3:  'Turning Right',
  4:  'Making U-Turn',
  5:  'Changing Lanes',
  6:  'Merging',
  7:  'Overtaking/Passing',
  8:  'Negotiating a Curve',
  9:  'Entering Traffic Lane',
  10: 'Leaving Traffic Lane',
  11: 'Parked',
  12: 'Starting in Traffic',
  13: 'Avoiding Object in Road',
  14: 'Decelerating (slowing)',
  15: 'Backing',
  16: 'Slowing or Stopped in Traffic',
  17: 'Other',
  99: 'Unknown',
};

// V22 – Extent of Damage
export const DAMAGE_EXTENT: Record<number, string> = {
  0: 'No Damage',
  2: 'Minor Damage',
  4: 'Functional Damage',
  5: 'Disabling Damage',
  9: 'Unknown',
};

// V23 – Vehicle Towed
export const TOWED: Record<number, string> = {
  1: 'Towed – Disabling Damage',
  2: 'Towed – Not Due to Disabling Damage',
  3: 'Not Towed',
  9: 'Unknown',
};

// V24 – Areas of Damage (clock-position codes)
export const DAMAGE_AREA: Record<number, string> = {
  1:  'Top/Roof',
  2:  '2 o\'clock (Right Front)',
  3:  '3 o\'clock (Right)',
  4:  '4 o\'clock (Right Rear)',
  5:  '5 o\'clock (Rear Right)',
  6:  '6 o\'clock (Rear)',
  7:  '7 o\'clock (Rear Left)',
  8:  '8 o\'clock (Left Rear)',
  9:  '9 o\'clock (Left)',
  10: '10 o\'clock (Left Front)',
  11: '11 o\'clock (Front Left)',
  12: '12 o\'clock (Front)',
  13: 'Top/Roof',
  14: 'Undercarriage',
  99: 'Unknown',
};

// V19 – Contributing Circumstances
export const CONTRIBUTING_CIRC: Record<number, string> = {
  1:  'Inattentive (Talking, Eating, etc.)',
  2:  'Failed to Keep in Proper Lane',
  3:  'Following Too Closely',
  4:  'Failed to Yield Right-of-Way',
  5:  'Made Improper Turn',
  6:  'Failed to Obey Traffic Signs, Signals, or Officer',
  7:  'Operated Motor Vehicle in Aggressive Manner',
  8:  'Operated Without Required Equipment',
  9:  'Speed Too Fast for Conditions',
  10: 'Exceeded Authorized Speed Limit',
  11: 'Under the Influence of Alcohol, Drugs, or Medication',
  12: 'Wrong Side or Wrong Way',
  13: 'Swerved or Avoided',
  14: 'Overcorrecting/Oversteering',
  15: 'Improper Backing',
  16: 'Distracted (Phone, Navigation, etc.)',
  17: 'Other Improper Action',
  99: 'None',
};

// R1 – Roadway Functional Classification
export const FUNCTIONAL_CLASS: Record<number, string> = {
  1:  'Rural – Principal Arterial (Interstate)',
  2:  'Rural – Principal Arterial (Other)',
  6:  'Rural – Minor Arterial',
  7:  'Rural – Major Collector',
  8:  'Rural – Minor Collector',
  9:  'Rural – Local',
  11: 'Urban – Principal Arterial (Interstate)',
  12: 'Urban – Principal Arterial (Other Freeway/Expressway)',
  14: 'Urban – Other Principal Arterial',
  16: 'Urban – Minor Arterial',
  17: 'Urban – Collector',
  19: 'Urban – Local',
  99: 'Unknown',
};

// R4 – Access Control
export const ACCESS_CONTROL: Record<number, string> = {
  1: 'Full Access Control',
  2: 'Partial Access Control',
  3: 'No Access Control',
  9: 'Unknown',
};

// R15 – Roadway Lighting
export const ROADWAY_LIGHTING: Record<number, string> = {
  1: 'Continuous Street Lighting (lighted)',
  2: 'Roadway Not Lighted',
  3: 'Roadway Lighted (non-continuous)',
  4: 'Roadway Lighting Unknown',
  9: 'Unknown',
};

// R8 – Centerline Pavement Marking
export const PAVEMENT_CENTERLINE: Record<number, string> = {
  0: 'No Centerline Marking',
  1: 'Centerline Only',
  2: 'No-Passing Zone Markings',
  9: 'Unknown',
};

// R9 – Edgeline Pavement Marking
export const PAVEMENT_EDGELINE: Record<number, string> = {
  0: 'No Edgeline Marking',
  1: 'Right Edgeline Only',
  2: 'Both Edgelines',
  9: 'Unknown',
};

// R10 – Lane Line Pavement Marking
export const PAVEMENT_LANE_LINE: Record<number, string> = {
  0: 'No Lane Lines',
  1: 'Lane Lines Present',
  9: 'Unknown',
};

// P3 – Sex
export const SEX_CODE: Record<number, string> = {
  1: 'Female',
  2: 'Male',
  9: 'Unknown',
};

// P4 – Person Type
export const PERSON_TYPE: Record<number, string> = {
  1: 'Driver',
  2: 'Passenger',
  3: 'Occupant of MV (Non-Transport)',
  4: 'Bicyclist',
  5: 'Other Pedalcyclist',
  6: 'Pedestrian',
  7: 'Other Non-Motorist',
  8: 'Unknown Person Type',
  9: 'Non-Occupant',
};

// P5 – Injury Status
export const INJURY_STATUS: Record<number, string> = {
  1: 'Fatal',
  2: 'Suspected Serious Injury',
  3: 'Suspected Minor Injury',
  4: 'Possible Injury',
  5: 'No Apparent Injury',
  9: 'Unknown',
};

// P7 – Seating Row
export const SEATING_ROW: Record<number, string> = {
  1: 'Row 1 (Front)',
  2: 'Row 2',
  3: 'Row 3 or Beyond',
  9: 'Unknown',
};

// P7 – Seating Position (within row)
export const SEATING_SEAT: Record<number, string> = {
  1: 'Left',
  2: 'Middle',
  3: 'Right',
  7: 'Entire Front Seat',
  9: 'Unknown',
};

// P8 – Restraint System Use
export const RESTRAINT: Record<number, string> = {
  1:  'Lap Belt Only',
  2:  'Shoulder Belt Only',
  3:  'Lap and Shoulder Belt',
  4:  'Child Restraint System – Forward Facing',
  5:  'Child Restraint System – Rear Facing',
  6:  'Booster Seat',
  7:  'Helmet',
  8:  'Reflective Clothing',
  9:  'Lighting Equipment',
  10: 'Other Protective Equipment',
  14: 'No Restraint Used or Helmet – Motorcycle',
  15: 'No Restraint Used – Other',
  98: 'Other',
  99: 'Unknown',
};

// P10 – Ejection
export const EJECTION: Record<number, string> = {
  0: 'Not Ejected',
  1: 'Fully Ejected',
  2: 'Partially Ejected',
  3: 'Ejected – Unknown Degree',
  9: 'Unknown',
};

// P13 – Speeding-Related
export const SPEEDING: Record<number, string> = {
  1: 'No',
  2: 'Yes – Exceeded Speed Limit',
  3: 'Yes – Too Fast for Conditions',
  9: 'Unknown',
};

// P14 – Driver Actions at Time of Crash
export const DRIVER_ACTION: Record<number, string> = {
  1:  'No Improper Action',
  2:  'Failure to Yield Right-of-Way',
  3:  'Failure to Obey Traffic Signs, Signals, or Officer',
  4:  'Wrong Side or Wrong Way',
  5:  'Made Improper Turn',
  6:  'Ran Off Road',
  7:  'Made Improper Lane Change',
  8:  'Followed Too Closely',
  9:  'Operating Vehicle in Erratic, Reckless, or Negligent Manner',
  10: 'Swerving or Avoiding Due to Wind, Slippery Surface, Vehicle, Object, Non-Motorist in Road',
  11: 'Over-Correcting/Over-Steering',
  12: 'Driving Without Required Equipment',
  13: 'Operating Beyond Driver Capability',
  14: 'Distracted (Phone, Navigation, etc.)',
  15: 'Inattentive',
  98: 'Other Improper Action',
  99: 'Unknown',
};

// C1 / R2 – Route Signing / Route Type
export const ROUTE_TYPE: Record<number, string> = {
  1:  'Interstate',
  2:  'U.S. Highway',
  3:  'State Route/Highway',
  4:  'County Road',
  5:  'City/Township Street',
  6:  'Forest Road',
  7:  'Park Road',
  8:  'Other',
  99: 'Unknown',
};

// C5 – Route Direction
export const ROUTE_DIRECTION: Record<number, string> = {
  1: 'North',
  2: 'South',
  3: 'East',
  4: 'West',
  9: 'Not Applicable / Unknown',
};

// P24 – Source of Transport to Medical Facility
export const TRANSPORT_SOURCE: Record<number, string> = {
  1: 'EMS Air',
  2: 'EMS Ground',
  3: 'Law Enforcement',
  4: 'Private / Personal Vehicle',
  5: 'Walked / Left on Own',
  6: 'Other',
  9: 'Unknown',
};

// R15 – Bicycle Facility Type
export const BICYCLE_FACILITY: Record<number, string> = {
  1: 'Bike Lane',
  2: 'Shared Use Path / Trail',
  3: 'Paved Shoulder',
  4: 'Wide Curb Lane',
  5: 'Signed Shared Roadway / Bicycle Boulevard',
  6: 'No Bicycle Facility',
  9: 'Unknown',
};

// R15 – Bicycle Signed Route
export const BICYCLE_SIGNED_ROUTE: Record<number, string> = {
  1: 'U.S. Bicycle Route System',
  2: 'State Signed Bicycle Route',
  3: 'Local Signed Bicycle Route',
  4: 'No Signed Bicycle Route',
  9: 'Unknown',
};

// P4 SF2 – Incident Responder Type
export const INCIDENT_RESPONDER: Record<number, string> = {
  1: 'Not an Incident Responder',
  2: 'Fire Fighter',
  3: 'Law Enforcement Officer',
  4: 'EMS Personnel',
  5: 'Other',
  9: 'Unknown',
};

// P9 – Airbag Deployed (location/status)
export const AIRBAG: Record<number, string> = {
  1:  'Frontal — Deployed',
  2:  'Side — Deployed',
  3:  'Curtain — Deployed',
  4:  'Knee / Leg — Deployed',
  5:  'Air Belt — Deployed',
  6:  'Other — Deployed',
  7:  'Frontal — Not Deployed',
  8:  'Side — Not Deployed',
  9:  'No Airbag Present',
  10: 'Deployed — Unknown Location',
  11: 'Not Deployed',
  99: 'Unknown',
};

// P11 – Driver License Jurisdiction Type
export const DL_JURISDICTION_TYPE: Record<number, string> = {
  1: 'U.S. State',
  2: 'Canadian Province / Territory',
  3: 'Mexico',
  4: 'Other Country',
  5: 'U.S. Military',
  6: 'U.S. Federal Government',
  7: 'Not Licensed',
  9: 'Unknown',
};

// P12 – Driver License Class
export const DL_CLASS: Record<number, string> = {
  1: 'Class A — CDL',
  2: 'Class B — CDL',
  3: 'Class C — CDL',
  4: 'Class D — Non-Commercial',
  5: 'Motorcycle Only',
  6: 'Other',
  9: 'Unknown',
};

// P12 – Driver License Endorsement
export const DL_ENDORSEMENT: Record<number, string> = {
  1: 'H — Hazardous Materials',
  2: 'N — Tank Vehicles',
  3: 'P — Passenger',
  4: 'S — School Bus',
  5: 'T — Double / Triple Trailers',
  6: 'X — Hazmat + Tank',
  7: 'None',
  8: 'Other',
  9: 'Unknown',
};

// P16 – Driver License Restriction
export const DL_RESTRICTION: Record<number, string> = {
  1: 'Corrective Lenses Required',
  2: 'Vehicle Without Air Brakes Only',
  3: 'CDL Intrastate Only',
  4: 'Restricted to Daylight Only',
  5: 'Limited to Vehicles Not Requiring CDL',
  6: 'Other Restriction',
  9: 'Unknown',
};

// P17 SF1 – Driver License Status Type
export const DL_STATUS_TYPE: Record<number, string> = {
  1: 'Valid',
  2: 'Suspended',
  3: 'Revoked',
  4: 'Cancelled / Denied',
  5: 'Expired',
  6: 'No License',
  9: 'Unknown',
};

// P17 SF2 – Driver License Status Detail
export const DL_STATUS: Record<number, string> = {
  1: 'Under Suspension — Moving Violation',
  2: 'Under Suspension — DUI/DWI',
  3: 'Under Suspension — Other',
  4: 'Under Revocation',
  5: 'Under Cancellation / Denial',
  6: 'Expired License',
  7: 'No License — Never Licensed',
  9: 'Unknown',
};

// P18 SF1 – Distracted Action
export const DISTRACTED_ACTION: Record<number, string> = {
  1: 'Not Distracted',
  2: 'Looked But Did Not See',
  3: 'Distracted by Other Occupant',
  4: 'Outside Person, Object, or Event',
  5: 'Use of Electronic Communication Device',
  6: 'Use of Other Technology Device',
  7: 'Other Distraction Inside Vehicle',
  8: 'Inattentive',
  9: 'Unknown',
};

// P18 SF2 – Distracted Source
export const DISTRACTED_SOURCE: Record<number, string> = {
  1:  'Cell Phone — Talking',
  2:  'Cell Phone — Texting / Email',
  3:  'Navigation Device',
  4:  'Radio / CD / MP3',
  5:  'In-Vehicle Technology (Other)',
  6:  'Other Electronic Device',
  7:  'Passenger',
  8:  'Animal in Vehicle',
  9:  'Personal Hygiene',
  10: 'Food / Drink',
  11: 'External Distraction',
  12: 'Other',
  99: 'Unknown',
};

// P19 – Driver Condition at Time of Crash
export const DRIVER_CONDITION: Record<number, string> = {
  1: 'Apparently Normal',
  2: 'Physical Impairment',
  3: 'Emotional (Upset, Depressed, etc.)',
  4: 'Fell Asleep, Fainted, Fatigued, or Exhausted',
  5: 'Under Influence of Alcohol / Drugs',
  6: 'Ill',
  7: 'Other',
  9: 'Unknown',
};

// P21 SF1 – Alcohol Test Status
export const ALCOHOL_TEST_STATUS: Record<number, string> = {
  1: 'Test Given',
  2: 'Test Refused',
  3: 'No Test Given',
  4: 'Test Given — Results Unknown',
  9: 'Unknown',
};

// P21 SF2 – Alcohol Test Type
export const ALCOHOL_TEST_TYPE: Record<number, string> = {
  1: 'Blood',
  2: 'Breath',
  3: 'Urine',
  4: 'Other',
  9: 'Unknown',
};

// P23 SF1 – Drug Test Status
export const DRUG_TEST_STATUS: Record<number, string> = {
  1: 'Test Given',
  2: 'Test Refused',
  3: 'No Test Given',
  4: 'Test Given — Results Unknown',
  9: 'Unknown',
};

// P23 SF2 – Drug Test Type
export const DRUG_TEST_TYPE: Record<number, string> = {
  1: 'Blood',
  2: 'Urine',
  3: 'Other',
  9: 'Unknown',
};

// P23 SF3 – Drug Test Result (substance detected)
export const DRUG_TEST_RESULT: Record<number, string> = {
  1:  'Amphetamines',
  2:  'Barbiturates',
  3:  'Benzodiazepines',
  4:  'Cannabis',
  5:  'Cocaine',
  6:  'Hallucinogens',
  7:  'Heroin / Opiates',
  8:  'Phencyclidine (PCP)',
  9:  'Prescription Drugs',
  10: 'Over-the-Counter Drugs',
  11: 'Other Drugs',
  12: 'Not Tested for Drugs',
  99: 'Unknown',
};

// P25 – Injury Area (body region)
export const INJURY_AREA: Record<number, string> = {
  1:  'Head / Face',
  2:  'Eye',
  3:  'Neck',
  4:  'Chest',
  5:  'Back',
  6:  'Shoulder / Upper Arm',
  7:  'Forearm / Elbow / Hand / Wrist',
  8:  'Abdomen / Pelvis',
  9:  'Hip / Upper Leg',
  10: 'Knee / Lower Leg / Foot / Ankle',
  11: 'Entire Body',
  12: 'Other',
  13: 'No Injury',
  99: 'Unknown',
};

// P27 – Injury Severity (agency-reported, older KABCO classification)
export const INJURY_SEVERITY: Record<number, string> = {
  1: 'Fatal',
  2: 'Incapacitating Injury (A)',
  3: 'Non-Incapacitating Injury (B)',
  4: 'Possible Injury (C)',
  5: 'No Injury (O)',
  9: 'Unknown',
};

// ── Fatal Section (F1–F3) ─────────────────────────────────────────────────────

// F3 – Drug Test Result (single code, distinct from P23 list)
// Reuses DRUG_TEST_RESULT map above.

// ── Non-Motorist Section (NM1–NM6) ───────────────────────────────────────────

// NM1 SF2 – Non-Motorist Action/Circumstance at Time of Crash
export const NM_ACTION_CIRC: Record<number, string> = {
  1:  'Walking Along Roadway',
  2:  'Working in Roadway',
  3:  'Standing in Roadway',
  4:  'Riding a Bicycle or E-Scooter',
  5:  'Exiting/Entering Parked Vehicle',
  6:  'Playing/Activity in Roadway',
  7:  'Crossing at Intersection',
  8:  'Crossing Not at Intersection',
  9:  'Traveling Along Roadway (not in crosswalk)',
  10: 'Working on Traffic Control Device',
  11: 'Pushing Disabled Vehicle',
  12: 'Other Working',
  13: 'Other Not in Roadway',
  99: 'Unknown',
};

// NM2 – Non-Motorist Origin/Destination
export const NM_ORIGIN_DESTINATION: Record<number, string> = {
  1: 'Home',
  2: 'Work',
  3: 'School',
  4: 'Recreation',
  5: 'Shopping',
  6: 'Medical/Dental',
  7: 'Other',
  9: 'Unknown',
};

// NM3 – Non-Motorist Contributing Action
export const NM_CONTRIBUTING_ACTION: Record<number, string> = {
  1: 'Dart/Dash',
  2: 'Failure to Yield Right of Way',
  3: 'Failure to Obey Traffic Control Device',
  4: 'Inattentive/Distracted',
  5: 'Other',
  6: 'None',
  9: 'Unknown',
};

// NM4 – Non-Motorist Location at Crash
export const NM_LOCATION_AT_CRASH: Record<number, string> = {
  1: 'At Intersection',
  2: 'Intersection Related',
  3: 'Driveway Access',
  4: 'Alley',
  5: 'In Roadway (not at intersection)',
  6: 'Not in Roadway',
  9: 'Unknown',
};

// NM5 – Non-Motorist Initial Contact Point (clock position)
export const NM_CONTACT_POINT: Record<number, string> = {
  1:  'Front',
  2:  'Front-Right',
  3:  'Right',
  4:  'Rear-Right',
  5:  'Rear',
  6:  'Rear-Left',
  7:  'Left',
  8:  'Front-Left',
  9:  'Unknown',
};

// NM6 – Non-Motorist Safety Equipment Used
export const NM_SAFETY_EQUIPMENT: Record<number, string> = {
  1: 'Helmet',
  2: 'Protective Padding',
  3: 'Protective Clothing',
  4: 'Reflective Clothing',
  5: 'Lighting Equipment',
  6: 'Other',
  9: 'Unknown',
};

// ── Large Vehicle / HazMat Section (LV1–LV11) ────────────────────────────────

// LV1 SF1 – CMV Driver License Status
export const CMV_LICENSE_STATUS: Record<number, string> = {
  1: 'Valid',
  2: 'Expired',
  3: 'Suspended',
  4: 'Revoked',
  5: 'Cancelled',
  6: 'Denied',
  7: 'Not Required',
  9: 'Unknown',
};

// LV1 SF2 – CDL Compliance
export const CDL_COMPLIANCE: Record<number, string> = {
  1: 'Yes, Properly Licensed',
  2: 'No, Not Properly Licensed',
  3: 'Not Applicable',
  9: 'Unknown',
};

// LV3 – Carrier ID Type
export const CARRIER_ID_TYPE: Record<number, string> = {
  1: 'US DOT Number',
  2: 'ICC/MC Number',
  3: 'State Issued Number',
  4: 'Other',
  9: 'Unknown',
};

// LV4 – Carrier Type
export const CARRIER_TYPE: Record<number, string> = {
  1: 'Interstate Carrier',
  2: 'Intrastate Carrier',
  3: 'Not in Commerce',
  4: 'Government',
  5: 'Other',
  9: 'Unknown',
};

// LV5 – Vehicle Configuration
export const VEHICLE_CONFIG: Record<number, string> = {
  1: 'Single Unit Truck (2-axle)',
  2: 'Single Unit Truck (3+ axle)',
  3: 'Truck Bobtail',
  4: 'Tractor Semi-Trailer',
  5: 'Tractor/Doubles',
  6: 'Tractor/Triples',
  7: 'Other',
  9: 'Unknown',
};

// LV6 – Vehicle Permitted Oversize/Overweight
export const VEHICLE_PERMITTED: Record<number, string> = {
  1: 'Oversize/Overweight Permit Required and On File',
  2: 'Special Use Permit',
  3: 'None Required',
  9: 'Unknown',
};

// LV7 – Cargo Body Type
export const CARGO_BODY_TYPE: Record<number, string> = {
  1:  'Bus',
  2:  'Concrete Mixer',
  3:  'Dump',
  4:  'Enclosed Box',
  5:  'Flatbed',
  6:  'Grain/Chips/Gravel',
  7:  'Hopper/Grain',
  8:  'Intermodal Container',
  9:  'Log/Pole',
  10: 'Other',
  11: 'Pole Trailer',
  12: 'Tank',
  13: 'Truck Tractor (Bobtail)',
  14: 'Van/Enclosed Box',
  15: 'Vehicle Towing Another Motor Vehicle',
  99: 'Unknown',
};

// LV9 – HazMat Released
export const HM_RELEASED: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

// LV11 – Special Vehicle Use / Sizing Permit
export const LV_SPECIAL_SIZING: Record<number, string> = {
  1: 'Single Item',
  2: 'Excessive Length',
  3: 'Excessive Height',
  4: 'Excessive Width',
  5: 'Excessive Weight',
  6: 'Other',
  9: 'Unknown',
};

// ── Vehicle Automation Section (DV1) ─────────────────────────────────────────

// DV1 SF1 – Automation Present
export const AUTOMATION_PRESENT: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

// DV1 SF2/SF3 – SAE J3016 Automation Level
export const AUTOMATION_LEVEL: Record<number, string> = {
  0: 'Level 0 — No Automation',
  1: 'Level 1 — Driver Assistance',
  2: 'Level 2 — Partial Automation',
  3: 'Level 3 — Conditional Automation',
  4: 'Level 4 — High Automation',
  5: 'Level 5 — Full Automation',
  9: 'Unknown',
};
