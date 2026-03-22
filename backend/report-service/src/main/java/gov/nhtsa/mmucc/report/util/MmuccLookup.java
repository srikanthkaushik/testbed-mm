package gov.nhtsa.mmucc.report.util;

import java.util.Map;

/**
 * Static lookup maps for all MMUCC coded values.
 * Mirrors the mmucc-lookup.ts maps in the Angular front-end.
 */
public final class MmuccLookup {

    private MmuccLookup() {}

    /** Returns "code — label" if found, or "code" if not in map, or "—" if code is null. */
    public static String label(Integer code, Map<Integer, String> map) {
        if (code == null) return "—";
        String desc = map.get(code);
        return desc != null ? code + " \u2014 " + desc : String.valueOf(code);
    }

    /** Returns raw label string without the code prefix. */
    public static String labelOnly(Integer code, Map<Integer, String> map) {
        if (code == null) return "—";
        String desc = map.get(code);
        return desc != null ? desc : String.valueOf(code);
    }

    // ── Crash ──────────────────────────────────────────────────────────────

    public static final Map<Integer, String> CRASH_SEVERITY = Map.of(
        1, "Fatal",
        2, "Serious Injury",
        3, "Minor Injury",
        4, "Possible Injury",
        5, "PDO"
    );

    public static final Map<Integer, String> CRASH_TYPE = Map.ofEntries(
        Map.entry(0,  "Not Collision w/Motor Vehicle"),
        Map.entry(1,  "Rear-End"),
        Map.entry(2,  "Head-On"),
        Map.entry(3,  "Rear-to-Rear"),
        Map.entry(4,  "Angle"),
        Map.entry(5,  "Sideswipe \u2013 Same Dir"),
        Map.entry(6,  "Sideswipe \u2013 Opp Dir"),
        Map.entry(7,  "Not Collision \u2013 Ran Off Road Right"),
        Map.entry(8,  "Not Collision \u2013 Ran Off Road Left"),
        Map.entry(9,  "Not Collision \u2013 Other"),
        Map.entry(10, "Unknown")
    );

    public static final Map<Integer, String> HARMFUL_EVENT = Map.ofEntries(
        Map.entry(1,  "Rollover/Overturn"),
        Map.entry(2,  "Fire/Explosion"),
        Map.entry(3,  "Immersion/Submersion"),
        Map.entry(4,  "Gas Inhalation"),
        Map.entry(5,  "Fell/Jumped from Vehicle"),
        Map.entry(6,  "Injured in Vehicle"),
        Map.entry(7,  "Thrown/Falling Object"),
        Map.entry(8,  "Other Non-Collision"),
        Map.entry(9,  "Pedestrian"),
        Map.entry(10, "Pedalcyclist"),
        Map.entry(11, "Railway Vehicle"),
        Map.entry(12, "Live Animal"),
        Map.entry(13, "Motor Vehicle In-Transport"),
        Map.entry(14, "Parked Motor Vehicle"),
        Map.entry(15, "Work Zone Maint Equipment"),
        Map.entry(16, "Struck by Airbag"),
        Map.entry(17, "Pothole"),
        Map.entry(18, "Object Not Fixed"),
        Map.entry(19, "Building"),
        Map.entry(20, "Impact Attenuator/Crash Cushion"),
        Map.entry(21, "Bridge Overhead Structure"),
        Map.entry(22, "Bridge Pier or Support"),
        Map.entry(23, "Bridge Rail"),
        Map.entry(24, "Culvert"),
        Map.entry(25, "Curb"),
        Map.entry(26, "Ditch"),
        Map.entry(27, "Embankment"),
        Map.entry(28, "Guardrail Face"),
        Map.entry(29, "Guardrail End"),
        Map.entry(30, "Cable Barrier"),
        Map.entry(31, "Concrete Traffic Barrier"),
        Map.entry(32, "Other Traffic Barrier"),
        Map.entry(33, "Tree \u2013 Standing"),
        Map.entry(34, "Utility Pole/Light Support"),
        Map.entry(35, "Traffic Sign Support"),
        Map.entry(36, "Traffic Signal Support"),
        Map.entry(37, "Other Post, Pole or Support"),
        Map.entry(38, "Fence"),
        Map.entry(39, "Mailbox"),
        Map.entry(40, "Other Fixed Object"),
        Map.entry(41, "Pavement Surface Irregularity"),
        Map.entry(42, "Working on Vehicle"),
        Map.entry(43, "Unknown")
    );

    public static final Map<Integer, String> MANNER_COLLISION = Map.of(
        1, "Not Collision w/Motor Vehicle",
        2, "Rear-End",
        3, "Head-On",
        4, "Rear-to-Rear",
        5, "Angle",
        6, "Sideswipe \u2013 Same Direction",
        7, "Sideswipe \u2013 Opp Direction",
        8, "Unknown"
    );

    public static final Map<Integer, String> SOURCE_OF_INFO = Map.of(
        1, "Law Enforcement Report",
        2, "Other Records",
        3, "Unknown"
    );

    public static final Map<Integer, String> LIGHT_CONDITION = Map.of(
        1, "Daylight",
        2, "Dark \u2013 Not Lighted",
        3, "Dark \u2013 Lighted",
        4, "Dark \u2013 Unknown Lighting",
        5, "Dawn",
        6, "Dusk",
        7, "Other",
        8, "Unknown"
    );

    public static final Map<Integer, String> JUNCTION_LOCATION = Map.of(
        1, "Non-Junction",
        2, "Intersection",
        3, "Intersection-Related",
        4, "Driveway/Alley Access",
        5, "Entrance/Exit Ramp",
        6, "Railway Grade Crossing",
        7, "Crossover-Related",
        8, "Shared-Use Path/Trails",
        9, "Acceleration/Deceleration Lane",
        10, "Other"
    );

    public static final Map<Integer, String> WEATHER = Map.ofEntries(
        Map.entry(1,  "Clear"),
        Map.entry(2,  "Cloudy"),
        Map.entry(3,  "Rain"),
        Map.entry(4,  "Sleet/Hail"),
        Map.entry(5,  "Snow"),
        Map.entry(6,  "Fog/Smoke/Smog"),
        Map.entry(7,  "Severe Crosswinds"),
        Map.entry(8,  "Blowing Sand/Soil/Dirt"),
        Map.entry(9,  "Freezing Rain/Drizzle"),
        Map.entry(10, "Blowing Snow"),
        Map.entry(11, "Other"),
        Map.entry(12, "Unknown")
    );

    public static final Map<Integer, String> SURFACE_CONDITION = Map.of(
        1, "Dry",
        2, "Wet",
        3, "Snow/Slush",
        4, "Ice/Frost",
        5, "Sand/Mud/Dirt/Gravel",
        6, "Water (Standing/Moving)",
        7, "Oil",
        8, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> CONTRIBUTING_CIRC = Map.ofEntries(
        Map.entry(1,  "None"),
        Map.entry(2,  "Road Surface Condition"),
        Map.entry(3,  "Debris"),
        Map.entry(4,  "Rut/Holes/Bumps"),
        Map.entry(5,  "Worn Surface"),
        Map.entry(6,  "Other Road Condition"),
        Map.entry(7,  "View Obscured \u2013 Building/Trees"),
        Map.entry(8,  "View Obscured \u2013 Moving Vehicle"),
        Map.entry(9,  "Glare"),
        Map.entry(10, "Signage/Marking Inadequate"),
        Map.entry(11, "Shoulders Low/Soft/High"),
        Map.entry(12, "Work Zone"),
        Map.entry(13, "Unknown")
    );

    public static final Map<Integer, String> ALCOHOL_INVOLVEMENT = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> DRUG_INVOLVEMENT = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> DAY_OF_WEEK = Map.of(
        1, "Sunday",
        2, "Monday",
        3, "Tuesday",
        4, "Wednesday",
        5, "Thursday",
        6, "Friday",
        7, "Saturday"
    );

    public static final Map<Integer, String> ROUTE_TYPE = Map.of(
        1, "Interstate",
        2, "U.S. Highway",
        3, "State Highway",
        4, "County Road",
        5, "Local Street",
        6, "Other",
        7, "Unknown"
    );

    public static final Map<Integer, String> ROUTE_DIRECTION = Map.of(
        1, "North",
        2, "South",
        3, "East",
        4, "West"
    );

    public static final Map<Integer, String> REF_POINT_DIRECTION = Map.of(
        1, "N",
        2, "NE",
        3, "E",
        4, "SE",
        5, "S",
        6, "SW",
        7, "W",
        8, "NW"
    );

    public static final Map<Integer, String> LOC_FIRST_HARMFUL = Map.of(
        1, "On Roadway",
        2, "Shoulder",
        3, "Median",
        4, "Roadside",
        5, "Outside Right-of-Way",
        6, "Gore Area",
        7, "Separator",
        8, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> INTERSECTION_GEOMETRY = Map.of(
        1, "T-Intersection",
        2, "Y-Intersection",
        3, "Four-Way Intersection",
        4, "Five-Point or More",
        5, "Traffic Circle/Roundabout",
        6, "Interchange Area",
        7, "Other"
    );

    public static final Map<Integer, String> INTERSECTION_TRAFFIC_CTL = Map.of(
        0, "None",
        1, "Signal",
        2, "Stop Sign",
        3, "Yield Sign",
        4, "Warning Sign",
        5, "School Zone",
        6, "Flashing Beacon",
        7, "Other",
        8, "Unknown"
    );

    public static final Map<Integer, String> SCHOOL_BUS = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> WORK_ZONE = Map.of(
        0, "No",
        1, "Yes"
    );

    public static final Map<Integer, String> WORK_ZONE_LOCATION = Map.of(
        1, "Before Work Zone",
        2, "Advance Warning Area",
        3, "Transition Area",
        4, "Activity Area",
        5, "Termination Area"
    );

    public static final Map<Integer, String> WORK_ZONE_TYPE = Map.of(
        1, "Lane Closure",
        2, "Lane Shift/Crossover",
        3, "Work on Shoulder/Median",
        4, "Intermittent/Moving Work",
        5, "Other"
    );

    public static final Map<Integer, String> WORK_ZONE_WORKERS = Map.of(
        0, "None",
        1, "Present",
        9, "Unknown"
    );

    public static final Map<Integer, String> WORK_ZONE_LAW_ENF = Map.of(
        0, "None",
        1, "Present",
        9, "Unknown"
    );

    public static final Map<Integer, String> INTERSECTION_APPROACHES = Map.of(
        2, "2", 3, "3", 4, "4", 5, "5", 6, "6", 7, "7", 8, "8", 9, "9 or more"
    );

    // ── Vehicle ────────────────────────────────────────────────────────────

    public static final Map<Integer, String> UNIT_TYPE = Map.of(
        1, "Motor Vehicle in Transport",
        2, "Parked Motor Vehicle",
        3, "Working Non-Motorist",
        4, "Non-Motorist Other Than Working",
        5, "Non-Contact Vehicle"
    );

    public static final Map<Integer, String> BODY_TYPE = Map.ofEntries(
        Map.entry(1,  "Passenger Car"),
        Map.entry(2,  "Light Truck (Pickup)"),
        Map.entry(3,  "Light Truck (Van)"),
        Map.entry(4,  "Light Truck (SUV)"),
        Map.entry(5,  "Light Truck (Other)"),
        Map.entry(6,  "Large Truck"),
        Map.entry(7,  "Bus"),
        Map.entry(8,  "Motorcycle"),
        Map.entry(9,  "Moped"),
        Map.entry(10, "Bicycle"),
        Map.entry(11, "Pedestrian"),
        Map.entry(12, "Other"),
        Map.entry(13, "Unknown")
    );

    public static final Map<Integer, String> VEHICLE_SIZE = Map.of(
        1, "<10,000 lbs",
        2, "10,001\u201314,000 lbs",
        3, "14,001\u201316,000 lbs",
        4, "16,001\u201319,500 lbs",
        5, "19,501\u201326,000 lbs",
        6, ">26,000 lbs",
        7, "Unknown"
    );

    public static final Map<Integer, String> HM_PLACARD = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> SPECIAL_FUNCTION = Map.of(
        0, "None",
        1, "Taxi",
        2, "Bus",
        3, "Military",
        4, "Police",
        5, "Ambulance",
        6, "Fire Truck",
        7, "School Bus",
        8, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> EMERGENCY_USE = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> DIRECTION_OF_TRAVEL = Map.of(
        1, "North",
        2, "South",
        3, "East",
        4, "West",
        5, "Northeast",
        6, "Northwest",
        7, "Southeast",
        8, "Southwest",
        9, "Unknown"
    );

    public static final Map<Integer, String> TRAFFICWAY_TRAVEL_DIR = Map.of(
        1, "One-Way",
        2, "Two-Way"
    );

    public static final Map<Integer, String> TRAFFICWAY_DIVIDED = Map.of(
        0, "Undivided",
        1, "Divided"
    );

    public static final Map<Integer, String> TRAFFICWAY_BARRIER = Map.of(
        0, "None",
        1, "Median Barrier",
        9, "Unknown"
    );

    public static final Map<Integer, String> TRAFFICWAY_HOV_HOT = Map.of(
        0, "None",
        1, "HOV",
        2, "HOT",
        9, "Unknown"
    );

    public static final Map<Integer, String> HOV_CRASH = Map.of(
        0, "No",
        1, "Yes"
    );

    public static final Map<Integer, String> ROADWAY_ALIGNMENT = Map.of(
        1, "Straight",
        2, "Curve \u2013 Left",
        3, "Curve \u2013 Right",
        4, "Curve \u2013 Unknown Direction"
    );

    public static final Map<Integer, String> ROADWAY_GRADE = Map.of(
        1, "Level",
        2, "Hillcrest",
        3, "Grade \u2013 Unknown Direction",
        4, "Uphill",
        5, "Downhill",
        6, "Sag/Bottom"
    );

    public static final Map<Integer, String> MANEUVER = Map.of(
        0, "No Evasive Action",
        1, "Braking",
        2, "Steering \u2013 Left",
        3, "Steering \u2013 Right",
        4, "Braking and Steering",
        5, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> DAMAGE_EXTENT = Map.of(
        1, "No Damage",
        2, "Minor Damage",
        3, "Functional Damage",
        4, "Disabling Damage",
        5, "Unknown"
    );

    public static final Map<Integer, String> HIT_AND_RUN = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> TOWED = Map.of(
        0, "No",
        1, "Yes \u2013 Towed Due to Disabling Damage",
        2, "Yes \u2013 Towed Due to Non-Disabling Damage",
        9, "Unknown"
    );

    public static final Map<Integer, String> TRAFFIC_CONTROL = Map.ofEntries(
        Map.entry(0,  "No Controls"),
        Map.entry(1,  "Traffic Control Signal"),
        Map.entry(2,  "Flashing Traffic Control Signal"),
        Map.entry(3,  "Stop Sign"),
        Map.entry(4,  "Yield Sign"),
        Map.entry(5,  "Warning Sign"),
        Map.entry(6,  "School Zone Sign"),
        Map.entry(7,  "Construction Sign"),
        Map.entry(8,  "Officer/Flagger"),
        Map.entry(9,  "Work Zone Devices"),
        Map.entry(10, "Other"),
        Map.entry(11, "Unknown")
    );

    public static final Map<Integer, String> SEQUENCE_EVENTS = Map.ofEntries(
        Map.entry(1,  "Rollover"),
        Map.entry(2,  "Fire/Explosion"),
        Map.entry(3,  "Immersion"),
        Map.entry(4,  "Gas Inhalation"),
        Map.entry(5,  "Fell/Jumped from Vehicle"),
        Map.entry(6,  "Occupant Separated from Vehicle"),
        Map.entry(7,  "Ran Off Road Right"),
        Map.entry(8,  "Ran Off Road Left"),
        Map.entry(9,  "Cross Median"),
        Map.entry(10, "Cross Centerline"),
        Map.entry(11, "End Departure"),
        Map.entry(12, "Downhill Runaway"),
        Map.entry(13, "Separation of Units"),
        Map.entry(14, "Cargo/Equipment Loss"),
        Map.entry(15, "Explosion/Fire Non-Crash"),
        Map.entry(16, "Equipment Failure"),
        Map.entry(17, "Blowout/Flat Tire"),
        Map.entry(18, "Lost Control"),
        Map.entry(19, "Jackknife"),
        Map.entry(20, "In-Transport"),
        Map.entry(21, "Pedestrian"),
        Map.entry(22, "Pedalcyclist"),
        Map.entry(23, "Animal"),
        Map.entry(24, "Motor Vehicle In-Transport"),
        Map.entry(25, "Parked Motor Vehicle"),
        Map.entry(26, "Work Zone/Maintenance Equip"),
        Map.entry(27, "Railway Vehicle"),
        Map.entry(28, "Live Animal"),
        Map.entry(29, "Struck by Airbag"),
        Map.entry(30, "Pothole"),
        Map.entry(31, "Object Not Fixed"),
        Map.entry(32, "Building"),
        Map.entry(33, "Traffic Barrier"),
        Map.entry(34, "Traffic Sign Support"),
        Map.entry(35, "Other Post/Pole/Support"),
        Map.entry(36, "Fence"),
        Map.entry(37, "Mailbox"),
        Map.entry(38, "Other Fixed Object"),
        Map.entry(39, "Unknown")
    );

    public static final Map<Integer, String> DAMAGE_AREA = Map.ofEntries(
        Map.entry(1,  "Top"),
        Map.entry(2,  "Undercarriage"),
        Map.entry(3,  "Front"),
        Map.entry(4,  "Front Right"),
        Map.entry(5,  "Right"),
        Map.entry(6,  "Back Right"),
        Map.entry(7,  "Back"),
        Map.entry(8,  "Back Left"),
        Map.entry(9,  "Left"),
        Map.entry(10, "Front Left")
    );

    // ── Person ─────────────────────────────────────────────────────────────

    public static final Map<Integer, String> SEX_CODE = Map.of(
        1, "Male",
        2, "Female",
        9, "Unknown"
    );

    public static final Map<Integer, String> PERSON_TYPE = Map.of(
        1, "Driver",
        2, "Passenger",
        3, "Occupant \u2013 Unknown Seat",
        4, "Non-Motorist \u2013 Unknown Occupant Type",
        5, "Pedestrian",
        6, "Pedalcyclist",
        7, "Other Cyclist",
        8, "Person on Personal Conveyance",
        9, "Unknown Occupant Type"
    );

    public static final Map<Integer, String> INCIDENT_RESPONDER = Map.of(
        0, "No",
        1, "Law Enforcement",
        2, "Fire/Rescue",
        3, "Emergency Medical",
        4, "Other"
    );

    public static final Map<Integer, String> INJURY_STATUS = Map.of(
        1, "Fatal",
        2, "Suspected Serious Injury",
        3, "Suspected Minor Injury",
        4, "Possible Injury",
        5, "No Apparent Injury"
    );

    public static final Map<Integer, String> SEATING_ROW = Map.of(
        1, "Front",
        2, "Second",
        3, "Third",
        4, "Fourth or More",
        5, "Trailing Unit",
        6, "Unknown"
    );

    public static final Map<Integer, String> SEATING_SEAT = Map.of(
        1, "Left",
        2, "Middle",
        3, "Right",
        4, "Unknown"
    );

    public static final Map<Integer, String> RESTRAINT = Map.of(
        0, "None",
        1, "Lap Belt Only",
        2, "Shoulder Belt Only",
        3, "Lap and Shoulder Belt",
        4, "Child Restraint System",
        5, "Booster Seat",
        6, "Helmet",
        7, "Other",
        8, "Unknown"
    );

    public static final Map<Integer, String> YES_NO = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> EJECTION = Map.of(
        0, "Not Ejected",
        1, "Ejected \u2013 Partial",
        2, "Ejected \u2013 Total",
        3, "Unknown"
    );

    public static final Map<Integer, String> AIRBAG = Map.of(
        0, "Not Deployed",
        1, "Front Deployed",
        2, "Side Deployed",
        3, "Curtain Deployed",
        4, "Knee Deployed",
        5, "Seat-Cushion Deployed",
        6, "Other Deployed",
        7, "Unknown"
    );

    public static final Map<Integer, String> DL_JURISDICTION_TYPE = Map.of(
        1, "U.S. State",
        2, "Canadian Province",
        3, "Other Country",
        4, "U.S. Territory",
        5, "Unknown"
    );

    public static final Map<Integer, String> DL_CLASS = Map.of(
        1, "A",
        2, "B",
        3, "C",
        4, "D",
        5, "M",
        6, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> DL_ENDORSEMENT = Map.of(
        0, "None",
        1, "H \u2013 Hazardous Materials",
        2, "N \u2013 Tank Vehicle",
        3, "P \u2013 Passenger",
        4, "S \u2013 School Bus",
        5, "T \u2013 Double/Triple Trailers",
        6, "X \u2013 H and N Combined",
        7, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> DL_RESTRICTION = Map.of(
        0, "None",
        1, "B \u2013 Corrective Lenses",
        2, "C \u2013 Mechanical Aid",
        3, "D \u2013 Prosthetic Aid",
        4, "E \u2013 Automatic Transmission",
        5, "F \u2013 Outside Mirror",
        6, "G \u2013 Limit Daylight Only",
        7, "H \u2013 Limit Employment",
        8, "I \u2013 Limit Intrastate Only",
        9, "J \u2013 Other"
    );

    public static final Map<Integer, String> DL_STATUS_TYPE = Map.of(
        1, "Valid",
        2, "Revoked",
        3, "Suspended",
        4, "Expired",
        5, "Cancelled",
        6, "Denied",
        7, "Disqualified",
        9, "Unknown"
    );

    public static final Map<Integer, String> DL_STATUS = Map.of(
        1, "Valid",
        2, "Revoked",
        3, "Suspended",
        4, "Expired",
        5, "Cancelled",
        6, "Denied",
        7, "Disqualified",
        9, "Unknown"
    );

    public static final Map<Integer, String> SPEEDING = Map.of(
        0, "No",
        1, "Yes \u2013 Exceeding Speed Limit",
        2, "Yes \u2013 Too Fast for Conditions",
        9, "Unknown"
    );

    public static final Map<Integer, String> DRIVER_ACTION = Map.ofEntries(
        Map.entry(0,  "None"),
        Map.entry(1,  "Inattention"),
        Map.entry(2,  "Distractions"),
        Map.entry(3,  "Careless Driving"),
        Map.entry(4,  "Erratic/Reckless"),
        Map.entry(5,  "Swerving/Avoiding"),
        Map.entry(6,  "Over-Correcting"),
        Map.entry(7,  "Making Improper Turn"),
        Map.entry(8,  "Changing Lanes Improperly"),
        Map.entry(9,  "Passing Improperly"),
        Map.entry(10, "Operating Vehicle Defectively"),
        Map.entry(11, "Failure to Yield"),
        Map.entry(12, "Failure to Obey Traffic Sign"),
        Map.entry(13, "Failure to Obey Traffic Signal"),
        Map.entry(14, "Failure to Keep in Proper Lane"),
        Map.entry(15, "Failure to Maintain Speed"),
        Map.entry(16, "Speeding"),
        Map.entry(17, "Alcohol Use"),
        Map.entry(18, "Drug Use"),
        Map.entry(19, "Other")
    );

    public static final Map<Integer, String> DISTRACTED_ACTION = Map.of(
        0, "None",
        1, "Electronic Device",
        2, "Passenger",
        3, "Other Inside Vehicle",
        4, "External Distraction",
        5, "Unknown"
    );

    public static final Map<Integer, String> DISTRACTED_SOURCE = Map.of(
        0, "None",
        1, "Cell Phone",
        2, "Navigation Device",
        3, "Radio/CD",
        4, "Eating/Drinking",
        5, "Smoking",
        6, "Other"
    );

    public static final Map<Integer, String> DRIVER_CONDITION = Map.of(
        1, "Apparently Normal",
        2, "Physical Impairment",
        3, "Emotional",
        4, "Ill",
        5, "Fatigued/Asleep",
        6, "Fell Asleep",
        7, "Under Influence \u2013 Alcohol",
        8, "Under Influence \u2013 Drugs",
        9, "Unknown"
    );

    public static final Map<Integer, String> ALCOHOL_TEST_STATUS = Map.of(
        0, "Not Tested",
        1, "Tested",
        2, "Test Refused",
        9, "Unknown"
    );

    public static final Map<Integer, String> ALCOHOL_TEST_TYPE = Map.of(
        0, "None",
        1, "Blood",
        2, "Breath",
        3, "Urine",
        9, "Unknown"
    );

    public static final Map<Integer, String> DRUG_TEST_STATUS = Map.of(
        0, "Not Tested",
        1, "Tested",
        9, "Unknown"
    );

    public static final Map<Integer, String> DRUG_TEST_TYPE = Map.of(
        0, "None",
        1, "Blood",
        2, "Urine",
        3, "Saliva/Oral Fluid",
        4, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> DRUG_TEST_RESULT = Map.of(
        1, "Cannabis",
        2, "CNS Depressant",
        3, "CNS Stimulant",
        4, "Hallucinogen",
        5, "Narcotic",
        6, "Inhalant",
        7, "Other Drug",
        8, "Negative",
        9, "Unknown"
    );

    public static final Map<Integer, String> TRANSPORT_SOURCE = Map.of(
        0, "None",
        1, "EMS Ground",
        2, "EMS Air",
        3, "Law Enforcement",
        4, "Private/Personal Vehicle",
        5, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> INJURY_AREA = Map.ofEntries(
        Map.entry(1,  "Head"),
        Map.entry(2,  "Face"),
        Map.entry(3,  "Eye"),
        Map.entry(4,  "Neck"),
        Map.entry(5,  "Chest"),
        Map.entry(6,  "Abdomen"),
        Map.entry(7,  "Back/Spine"),
        Map.entry(8,  "Shoulder/Upper Arm"),
        Map.entry(9,  "Elbow/Lower Arm/Hand"),
        Map.entry(10, "Hip/Pelvis"),
        Map.entry(11, "Upper Leg/Thigh"),
        Map.entry(12, "Knee"),
        Map.entry(13, "Lower Leg/Ankle/Foot"),
        Map.entry(14, "Entire Body"),
        Map.entry(15, "Unknown")
    );

    public static final Map<Integer, String> INJURY_SEVERITY = Map.of(
        1, "Fatal",
        2, "Incapacitating",
        3, "Non-Incapacitating",
        4, "Possible",
        5, "No Injury",
        9, "Unknown"
    );

    // ── Non-Motorist ───────────────────────────────────────────────────────

    public static final Map<Integer, String> NM_ACTION_CIRC = Map.of(
        1, "Crossing Roadway",
        2, "Walking/Cycling Along Roadway",
        3, "Working in Roadway",
        4, "Playing in Roadway",
        5, "Standing/Lying in Roadway",
        6, "Getting On/Off Vehicle",
        7, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> NM_ORIGIN_DESTINATION = Map.of(
        1, "Residence",
        2, "School",
        3, "Work",
        4, "Recreation",
        5, "Errand",
        6, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> NM_CONTRIBUTING_ACTION = Map.ofEntries(
        Map.entry(1,  "None"),
        Map.entry(2,  "Failure to Yield"),
        Map.entry(3,  "Failure to Obey Traffic Sign"),
        Map.entry(4,  "Failure to Obey Traffic Signal"),
        Map.entry(5,  "Inattention"),
        Map.entry(6,  "Improper Crossing"),
        Map.entry(7,  "Darting"),
        Map.entry(8,  "Lying in Road"),
        Map.entry(9,  "Not Visible (Dark Clothing)"),
        Map.entry(10, "Other"),
        Map.entry(11, "Unknown")
    );

    public static final Map<Integer, String> NM_LOCATION_AT_CRASH = Map.ofEntries(
        Map.entry(1,  "At Intersection"),
        Map.entry(2,  "Intersection-Related"),
        Map.entry(3,  "Driveway Access"),
        Map.entry(4,  "Entrance/Exit Ramp"),
        Map.entry(5,  "Shared-Use Path"),
        Map.entry(6,  "Non-Roadway"),
        Map.entry(7,  "Sidewalk"),
        Map.entry(8,  "Travel Lane"),
        Map.entry(9,  "Bicycle Lane"),
        Map.entry(10, "Shoulder"),
        Map.entry(11, "Median"),
        Map.entry(12, "Other"),
        Map.entry(13, "Unknown")
    );

    public static final Map<Integer, String> NM_CONTACT_POINT = Map.of(
        1, "Front",
        2, "Front Right",
        3, "Right",
        4, "Back Right",
        5, "Back",
        6, "Back Left",
        7, "Left",
        8, "Front Left",
        9, "Unknown"
    );

    public static final Map<Integer, String> NM_SAFETY_EQUIPMENT = Map.of(
        0, "None",
        1, "Helmet",
        2, "Reflective Clothing",
        3, "Lighting",
        4, "Other",
        9, "Unknown"
    );

    // ── Automation ─────────────────────────────────────────────────────────

    public static final Map<Integer, String> AUTOMATION_PRESENT = Map.of(
        0, "No",
        1, "Yes \u2013 Active",
        2, "Yes \u2013 Inactive",
        9, "Unknown"
    );

    public static final Map<Integer, String> AUTOMATION_LEVEL = Map.of(
        0, "No SAE Level",
        1, "Level 1 (Driver Assistance)",
        2, "Level 2 (Partial Automation)",
        3, "Level 3 (Conditional Automation)",
        4, "Level 4 (High Automation)",
        5, "Level 5 (Full Automation)"
    );

    // ── Large Vehicle ──────────────────────────────────────────────────────

    public static final Map<Integer, String> CMV_LICENSE_STATUS = Map.of(
        1, "Valid",
        2, "Revoked",
        3, "Suspended",
        4, "Expired",
        5, "No CDL Required",
        9, "Unknown"
    );

    public static final Map<Integer, String> CDL_COMPLIANCE = Map.of(
        1, "In Compliance",
        2, "Not In Compliance",
        9, "Unknown"
    );

    public static final Map<Integer, String> CARRIER_ID_TYPE = Map.of(
        1, "USDOT Number",
        2, "ICC/MC Number",
        3, "State Issued",
        4, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> CARRIER_TYPE = Map.of(
        1, "Interstate",
        2, "Intrastate Hazmat",
        3, "Intrastate Non-Hazmat",
        4, "Not In Commerce",
        9, "Unknown"
    );

    public static final Map<Integer, String> VEHICLE_CONFIG = Map.of(
        1, "Single Unit Truck (2-axle)",
        2, "Single Unit Truck (3+ axle)",
        3, "Truck Pulling Trailer",
        4, "Truck Tractor Only",
        5, "Truck Tractor/Semi-Trailer",
        6, "Truck Tractor/Double",
        7, "Truck Tractor/Triple",
        8, "Other",
        9, "Unknown"
    );

    public static final Map<Integer, String> CARGO_BODY = Map.ofEntries(
        Map.entry(1,  "Van/Enclosed Box"),
        Map.entry(2,  "Cargo Tank"),
        Map.entry(3,  "Flatbed"),
        Map.entry(4,  "Dump"),
        Map.entry(5,  "Concrete Mixer"),
        Map.entry(6,  "Auto Transporter"),
        Map.entry(7,  "Garbage/Refuse"),
        Map.entry(8,  "Log"),
        Map.entry(9,  "Intermodal Container Chassis"),
        Map.entry(10, "Vehicle Towing"),
        Map.entry(11, "Other"),
        Map.entry(12, "Unknown")
    );

    public static final Map<Integer, String> HM_RELEASED = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> VEHICLE_PERMITTED = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    public static final Map<Integer, String> SPECIAL_SIZING = Map.of(
        1, "Overwidth",
        2, "Overheight",
        3, "Overlength",
        4, "Overweight (Total)",
        5, "Overweight (Axle)"
    );

    // ── Roadway ────────────────────────────────────────────────────────────

    public static final Map<Integer, String> FUNCTIONAL_CLASS = Map.ofEntries(
        Map.entry(1,  "Rural Principal Arterial Interstate"),
        Map.entry(2,  "Rural Principal Arterial Other"),
        Map.entry(3,  "Rural Minor Arterial"),
        Map.entry(4,  "Rural Major Collector"),
        Map.entry(5,  "Rural Minor Collector"),
        Map.entry(6,  "Rural Local"),
        Map.entry(7,  "Urban Principal Arterial Interstate"),
        Map.entry(8,  "Urban Principal Arterial Other Freeways/Expressways"),
        Map.entry(9,  "Urban Principal Arterial Other"),
        Map.entry(10, "Urban Minor Arterial"),
        Map.entry(11, "Urban Collector"),
        Map.entry(12, "Urban Local")
    );

    public static final Map<Integer, String> NHS = Map.of(
        0, "No",
        1, "Yes"
    );

    public static final Map<Integer, String> ACCESS_CONTROL = Map.of(
        1, "Full Access Control",
        2, "Partial Access Control",
        3, "No Access Control"
    );

    public static final Map<Integer, String> ROADWAY_LIGHTING = Map.of(
        1, "Continuous",
        2, "At Intersection Only",
        3, "None",
        4, "Unknown"
    );

    public static final Map<Integer, String> PAVEMENT_MARKING = Map.of(
        0, "None",
        1, "Present",
        9, "Unknown"
    );

    public static final Map<Integer, String> BICYCLE_FACILITY = Map.of(
        0, "None",
        1, "Separated",
        2, "Bike Lane",
        3, "Shared Lane",
        4, "Unknown"
    );

    public static final Map<Integer, String> BICYCLE_SIGNED_ROUTE = Map.of(
        0, "No",
        1, "Yes",
        9, "Unknown"
    );

    // ── Fatal Section ──────────────────────────────────────────────────────

    public static final Map<Integer, String> AVOIDANCE_MANEUVER = Map.of(
        0, "No Evasive Action",
        1, "Braking",
        2, "Steering \u2013 Left",
        3, "Steering \u2013 Right",
        4, "Braking and Steering",
        5, "Other",
        9, "Unknown"
    );
}
