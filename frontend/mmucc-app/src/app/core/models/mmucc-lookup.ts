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
