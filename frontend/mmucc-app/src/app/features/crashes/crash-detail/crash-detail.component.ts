import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { switchMap, tap, catchError } from 'rxjs/operators';
import { EMPTY, of } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import { AuditLogEntry, CrashDetail, FatalSection, LargeVehicle, NonMotorist, VehicleAutomation, VehicleDetail, PersonDetail, TrafficControl } from '../../../core/models/crash.models';
import {
  MANNER_COLLISION,
  LIGHT_CONDITION,
  WEATHER_CONDITION,
  SURFACE_CONDITION,
  JUNCTION_TYPE,
  INTERSECTION_GEOMETRY,
  INTERSECTION_TRAFFIC_CTL,
  INVOLVEMENT,
  YES_NO,
  WORK_ZONE_LOCATION,
  WORK_ZONE_TYPE,
  LOC_FIRST_HARMFUL_EVENT,
  CRASH_TYPE,
  HARMFUL_EVENT,
  UNIT_TYPE,
  BODY_TYPE,
  TRAFFIC_CONTROL,
  DIRECTION_OF_TRAVEL,
  TRAFFICWAY_TRAVEL_DIR,
  TRAFFICWAY_DIVIDED,
  ROADWAY_ALIGNMENT,
  ROADWAY_GRADE,
  MANEUVER,
  DAMAGE_EXTENT,
  TOWED,
  DAMAGE_AREA,
  CONTRIBUTING_CIRC,
  FUNCTIONAL_CLASS,
  ACCESS_CONTROL,
  ROADWAY_LIGHTING,
  PAVEMENT_CENTERLINE,
  PAVEMENT_EDGELINE,
  PAVEMENT_LANE_LINE,
  ROUTE_TYPE,
  SEX_CODE,
  PERSON_TYPE,
  INJURY_STATUS,
  SEATING_ROW,
  SEATING_SEAT,
  RESTRAINT,
  EJECTION,
  SPEEDING,
  DRIVER_ACTION,
  ROUTE_DIRECTION,
  TRANSPORT_SOURCE,
  BICYCLE_FACILITY,
  BICYCLE_SIGNED_ROUTE,
  INCIDENT_RESPONDER,
  AIRBAG,
  DL_JURISDICTION_TYPE,
  DL_CLASS,
  DL_ENDORSEMENT,
  DL_RESTRICTION,
  DL_STATUS_TYPE,
  DL_STATUS,
  DISTRACTED_ACTION,
  DISTRACTED_SOURCE,
  DRIVER_CONDITION,
  ALCOHOL_TEST_STATUS,
  ALCOHOL_TEST_TYPE,
  DRUG_TEST_STATUS,
  DRUG_TEST_TYPE,
  DRUG_TEST_RESULT,
  INJURY_AREA,
  INJURY_SEVERITY,
  NM_ACTION_CIRC,
  NM_ORIGIN_DESTINATION,
  NM_CONTRIBUTING_ACTION,
  NM_LOCATION_AT_CRASH,
  NM_CONTACT_POINT,
  NM_SAFETY_EQUIPMENT,
  CMV_LICENSE_STATUS,
  CDL_COMPLIANCE,
  CARRIER_ID_TYPE,
  CARRIER_TYPE,
  VEHICLE_CONFIG,
  VEHICLE_PERMITTED,
  CARGO_BODY_TYPE,
  HM_RELEASED,
  LV_SPECIAL_SIZING,
  AUTOMATION_PRESENT,
  AUTOMATION_LEVEL,
} from '../../../core/models/mmucc-lookup';

export type DetailTab = 'overview' | 'vehicles' | 'persons' | 'roadway' | 'audit';

@Component({
  selector: 'app-crash-detail',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink, AlertComponent],
  templateUrl: './crash-detail.component.html',
  styleUrl: './crash-detail.component.scss',
})
export class CrashDetailComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly route        = inject(ActivatedRoute);
  private readonly router       = inject(Router);
  private readonly destroyRef   = inject(DestroyRef);

  readonly loading      = signal<boolean>(true);
  readonly errorMessage = signal<string>('');
  readonly crash        = signal<CrashDetail | null>(null);
  readonly activeTab    = signal<DetailTab>('overview');
  readonly auditLog     = signal<AuditLogEntry[]>([]);
  readonly auditLoading = signal<boolean>(false);

  // ── Delete state ───────────────────────────────────────────────────────────
  readonly deletingCrash     = signal<boolean>(false);
  readonly deletingVehicleId = signal<number | null>(null);
  readonly deletingPersonId  = signal<number | null>(null);
  readonly deleteError       = signal<string>('');

  // ── Lookup maps exposed for template use ───────────────────────────────────
  readonly MANNER_COLLISION        = MANNER_COLLISION;
  readonly LIGHT_CONDITION         = LIGHT_CONDITION;
  readonly WEATHER_CONDITION       = WEATHER_CONDITION;
  readonly SURFACE_CONDITION       = SURFACE_CONDITION;
  readonly JUNCTION_TYPE           = JUNCTION_TYPE;
  readonly INTERSECTION_GEOMETRY   = INTERSECTION_GEOMETRY;
  readonly INTERSECTION_TRAFFIC_CTL = INTERSECTION_TRAFFIC_CTL;
  readonly INVOLVEMENT             = INVOLVEMENT;
  readonly YES_NO                  = YES_NO;
  readonly WORK_ZONE_LOCATION      = WORK_ZONE_LOCATION;
  readonly WORK_ZONE_TYPE          = WORK_ZONE_TYPE;
  readonly LOC_FIRST_HARMFUL_EVENT = LOC_FIRST_HARMFUL_EVENT;
  readonly CRASH_TYPE              = CRASH_TYPE;
  readonly HARMFUL_EVENT           = HARMFUL_EVENT;
  readonly UNIT_TYPE               = UNIT_TYPE;
  readonly BODY_TYPE               = BODY_TYPE;
  readonly TRAFFIC_CONTROL         = TRAFFIC_CONTROL;
  readonly DIRECTION_OF_TRAVEL     = DIRECTION_OF_TRAVEL;
  readonly TRAFFICWAY_TRAVEL_DIR   = TRAFFICWAY_TRAVEL_DIR;
  readonly TRAFFICWAY_DIVIDED      = TRAFFICWAY_DIVIDED;
  readonly ROADWAY_ALIGNMENT       = ROADWAY_ALIGNMENT;
  readonly ROADWAY_GRADE           = ROADWAY_GRADE;
  readonly MANEUVER                = MANEUVER;
  readonly DAMAGE_EXTENT           = DAMAGE_EXTENT;
  readonly TOWED                   = TOWED;
  readonly DAMAGE_AREA             = DAMAGE_AREA;
  readonly CONTRIBUTING_CIRC       = CONTRIBUTING_CIRC;
  readonly FUNCTIONAL_CLASS        = FUNCTIONAL_CLASS;
  readonly ACCESS_CONTROL          = ACCESS_CONTROL;
  readonly ROADWAY_LIGHTING        = ROADWAY_LIGHTING;
  readonly PAVEMENT_CENTERLINE     = PAVEMENT_CENTERLINE;
  readonly PAVEMENT_EDGELINE       = PAVEMENT_EDGELINE;
  readonly PAVEMENT_LANE_LINE      = PAVEMENT_LANE_LINE;
  readonly ROUTE_TYPE              = ROUTE_TYPE;

  readonly SEX_CODE        = SEX_CODE;
  readonly PERSON_TYPE     = PERSON_TYPE;
  readonly INJURY_STATUS   = INJURY_STATUS;
  readonly SEATING_ROW     = SEATING_ROW;
  readonly SEATING_SEAT    = SEATING_SEAT;
  readonly RESTRAINT       = RESTRAINT;
  readonly EJECTION        = EJECTION;
  readonly SPEEDING             = SPEEDING;
  readonly DRIVER_ACTION        = DRIVER_ACTION;
  readonly ROUTE_DIRECTION      = ROUTE_DIRECTION;
  readonly TRANSPORT_SOURCE     = TRANSPORT_SOURCE;
  readonly BICYCLE_FACILITY     = BICYCLE_FACILITY;
  readonly BICYCLE_SIGNED_ROUTE = BICYCLE_SIGNED_ROUTE;
  readonly INCIDENT_RESPONDER   = INCIDENT_RESPONDER;
  readonly AIRBAG               = AIRBAG;
  readonly DL_JURISDICTION_TYPE = DL_JURISDICTION_TYPE;
  readonly DL_CLASS             = DL_CLASS;
  readonly DL_ENDORSEMENT       = DL_ENDORSEMENT;
  readonly DL_RESTRICTION       = DL_RESTRICTION;
  readonly DL_STATUS_TYPE       = DL_STATUS_TYPE;
  readonly DL_STATUS            = DL_STATUS;
  readonly DISTRACTED_ACTION    = DISTRACTED_ACTION;
  readonly DISTRACTED_SOURCE    = DISTRACTED_SOURCE;
  readonly DRIVER_CONDITION     = DRIVER_CONDITION;
  readonly ALCOHOL_TEST_STATUS  = ALCOHOL_TEST_STATUS;
  readonly ALCOHOL_TEST_TYPE    = ALCOHOL_TEST_TYPE;
  readonly DRUG_TEST_STATUS     = DRUG_TEST_STATUS;
  readonly DRUG_TEST_TYPE       = DRUG_TEST_TYPE;
  readonly DRUG_TEST_RESULT     = DRUG_TEST_RESULT;
  readonly INJURY_AREA          = INJURY_AREA;
  readonly INJURY_SEVERITY      = INJURY_SEVERITY;

  readonly NM_ACTION_CIRC         = NM_ACTION_CIRC;
  readonly NM_ORIGIN_DESTINATION  = NM_ORIGIN_DESTINATION;
  readonly NM_CONTRIBUTING_ACTION = NM_CONTRIBUTING_ACTION;
  readonly NM_LOCATION_AT_CRASH   = NM_LOCATION_AT_CRASH;
  readonly NM_CONTACT_POINT       = NM_CONTACT_POINT;
  readonly NM_SAFETY_EQUIPMENT    = NM_SAFETY_EQUIPMENT;
  readonly CMV_LICENSE_STATUS     = CMV_LICENSE_STATUS;
  readonly CDL_COMPLIANCE         = CDL_COMPLIANCE;
  readonly CARRIER_ID_TYPE        = CARRIER_ID_TYPE;
  readonly CARRIER_TYPE           = CARRIER_TYPE;
  readonly VEHICLE_CONFIG         = VEHICLE_CONFIG;
  readonly VEHICLE_PERMITTED      = VEHICLE_PERMITTED;
  readonly CARGO_BODY_TYPE        = CARGO_BODY_TYPE;
  readonly HM_RELEASED            = HM_RELEASED;
  readonly LV_SPECIAL_SIZING      = LV_SPECIAL_SIZING;
  readonly AUTOMATION_PRESENT     = AUTOMATION_PRESENT;
  readonly AUTOMATION_LEVEL       = AUTOMATION_LEVEL;

  readonly tabs: { id: DetailTab; label: string }[] = [
    { id: 'overview', label: 'Overview' },
    { id: 'vehicles', label: 'Vehicles' },
    { id: 'persons', label: 'Persons' },
    { id: 'roadway', label: 'Roadway' },
    { id: 'audit', label: 'Audit' },
  ];

  readonly crashId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('id'))
  );

  readonly pageTitle = computed<string>(() => {
    const c = this.crash();
    if (!c) return 'Crash Detail';
    return c.crashIdentifier ? `Crash ${c.crashIdentifier}` : `Crash #${c.crashId}`;
  });

  ngOnInit(): void {
    of(this.crashId())
      .pipe(
        tap(() => {
          this.loading.set(true);
          this.errorMessage.set('');
        }),
        switchMap((id) =>
          this.crashService.getCrash(id).pipe(
            catchError((err: unknown) => {
              const msg =
                err instanceof Error
                  ? err.message
                  : 'Failed to load crash record. Please try again.';
              this.errorMessage.set(msg);
              this.loading.set(false);
              return EMPTY;
            }),
          ),
        ),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((detail) => {
        this.crash.set(detail);
        this.loading.set(false);
      });
  }

  setTab(tab: DetailTab): void {
    this.activeTab.set(tab);
    if (tab === 'audit' && this.auditLog().length === 0 && !this.auditLoading()) {
      this.loadAuditLog();
    }
  }

  private loadAuditLog(): void {
    const id = this.crashId();
    if (!id) return;
    this.auditLoading.set(true);
    this.crashService.getAuditLog(id)
      .pipe(
        catchError(() => of([])),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(entries => {
        this.auditLog.set(entries);
        this.auditLoading.set(false);
      });
  }

  // ── Delete helpers ─────────────────────────────────────────────────────────

  confirmDeleteCrash(): void {
    this.deleteError.set('');
    this.crashService.deleteCrash(this.crashId())
      .pipe(
        catchError((err: unknown) => {
          this.deleteError.set(err instanceof Error ? err.message : 'Failed to delete crash.');
          this.deletingCrash.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => this.router.navigate(['/crashes']));
  }

  confirmDeleteVehicle(vehicleId: number): void {
    this.deleteError.set('');
    this.crashService.deleteVehicle(this.crashId(), vehicleId)
      .pipe(
        catchError((err: unknown) => {
          this.deleteError.set(err instanceof Error ? err.message : 'Failed to delete vehicle.');
          this.deletingVehicleId.set(null);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => {
        this.deletingVehicleId.set(null);
        this.crash.update(c => c ? {
          ...c,
          vehicles: c.vehicles.filter(v => v.vehicleId !== vehicleId),
        } : null);
      });
  }

  confirmDeletePerson(vehicleId: number, personId: number): void {
    this.deleteError.set('');
    this.crashService.deletePerson(this.crashId(), vehicleId, personId)
      .pipe(
        catchError((err: unknown) => {
          this.deleteError.set(err instanceof Error ? err.message : 'Failed to delete person.');
          this.deletingPersonId.set(null);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => {
        this.deletingPersonId.set(null);
        this.crash.update(c => c ? {
          ...c,
          persons: c.persons.filter(p => p.personId !== personId),
        } : null);
      });
  }

  // ── Formatting helpers ─────────────────────────────────────────────────────

  formatDate(iso: string | null): string {
    if (!iso) return '—';
    const [year, month, day] = iso.split('-');
    return `${month}/${day}/${year}`;
  }

  formatTime(t: string | null): string {
    if (!t) return '—';
    return t.substring(0, 5);   // "HH:mm:ss" → "HH:mm"
  }

  formatDateTime(dt: string | null): string {
    if (!dt) return '—';
    const d = new Date(dt);
    return d.toLocaleString('en-US', {
      month: '2-digit', day: '2-digit', year: 'numeric',
      hour: '2-digit', minute: '2-digit',
    });
  }

  formatCoord(n: number | null): string {
    return n != null ? n.toFixed(6) : '—';
  }

  nullOr(v: number | string | null | undefined): string {
    return v != null ? String(v) : '—';
  }

  severityLabel(code: number | null): string {
    const labels: Record<number, string> = {
      1: 'Fatal',
      2: 'Serious Injury',
      3: 'Minor Injury',
      4: 'Possible Injury',
      5: 'No Apparent Injury (PDO)',
    };
    return code != null ? (labels[code] ?? `Code ${code}`) : '—';
  }

  severityBadgeClass(code: number | null): string {
    const map: Record<number, string> = {
      1: 'badge--danger',
      2: 'badge--warning',
      3: 'badge--warning',
      4: 'badge--info',
      5: 'badge--neutral',
    };
    return code != null ? (map[code] ?? 'badge--neutral') : 'badge--neutral';
  }

  formatCodes(items: { code: number }[]): string {
    return items.map(i => i.code).join(', ');
  }

  /** Returns "N — Description" for a coded value, or "—" when null/undefined. */
  label(code: number | null | undefined, map: Record<number, string>): string {
    if (code == null) return '—';
    const desc = map[code];
    return desc ? `${code} — ${desc}` : `${code}`;
  }

  /** Returns comma-joined "N — Description" list for multi-value child rows. */
  labelList(items: { code: number }[], map: Record<number, string>): string {
    if (!items.length) return '—';
    return items.map(i => {
      const desc = map[i.code];
      return desc ? `${i.code} — ${desc}` : `${i.code}`;
    }).join('; ');
  }

  /** Returns "N — Description" for a traffic-control entry. */
  trafficControlLabel(items: TrafficControl[], map: Record<number, string>): string {
    if (!items.length) return '—';
    return items.map(i => {
      const desc = map[i.trafficControlCode];
      return desc ? `${i.trafficControlCode} — ${desc}` : `${i.trafficControlCode}`;
    }).join('; ');
  }

  dayLabel(code: number | null): string {
    const days: Record<number, string> = {
      1: 'Sunday', 2: 'Monday', 3: 'Tuesday', 4: 'Wednesday',
      5: 'Thursday', 6: 'Friday', 7: 'Saturday',
    };
    return code != null ? (days[code] ?? `Code ${code}`) : '—';
  }

  vehicleLabel(v: VehicleDetail): string {
    const parts: string[] = [];
    if (v.modelYear) parts.push(String(v.modelYear));
    if (v.make) parts.push(v.make);
    if (v.model) parts.push(v.model);
    return parts.length ? parts.join(' ') : `Unit ${v.unitNumber ?? v.vehicleId}`;
  }

  personLabel(p: PersonDetail): string {
    return p.personName ?? `Person ${p.personId}`;
  }

  injuryBadgeClass(code: number | null): string {
    const map: Record<number, string> = {
      1: 'badge--danger',
      2: 'badge--warning',
      3: 'badge--warning',
      4: 'badge--info',
      5: 'badge--neutral',
    };
    return code != null ? (map[code] ?? 'badge--neutral') : 'badge--neutral';
  }

  auditActionClass(action: string): string {
    const map: Record<string, string> = {
      CREATE: 'badge--success',
      UPDATE: 'badge--info',
      DELETE: 'badge--danger',
    };
    return map[action] ?? 'badge--neutral';
  }

  prettyJson(raw: string | null): string {
    if (!raw) return '';
    try { return JSON.stringify(JSON.parse(raw), null, 2); }
    catch { return raw; }
  }

  personGroupLabel(p: PersonDetail): string {
    if (p.vehicleUnitNumber != null) return `Unit ${p.vehicleUnitNumber}`;
    if (p.vehicleId != null) return `Vehicle ${p.vehicleId}`;
    return 'Non-Motorist';
  }

  formatAge(p: PersonDetail): string {
    if (p.ageYears != null) return `${p.ageYears} yrs`;
    if (p.dobYear) return `b. ${p.dobYear}`;
    return '—';
  }
}
