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
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { catchError } from 'rxjs/operators';
import { EMPTY } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { ReferenceService } from '../../../core/services/reference.service';
import { CrashRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import {
  CRASH_TYPE          as CRASH_TYPE_STATIC,
  HARMFUL_EVENT       as HARMFUL_EVENT_STATIC,
  MANNER_COLLISION,
  LOC_FIRST_HARMFUL_EVENT,
  LIGHT_CONDITION,
  WEATHER_CONDITION   as WEATHER_CONDITION_STATIC,
  SURFACE_CONDITION   as SURFACE_CONDITION_STATIC,
  JUNCTION_TYPE,
  INTERSECTION_GEOMETRY,
  INTERSECTION_TRAFFIC_CTL,
  INVOLVEMENT,
  YES_NO,
  WORK_ZONE_LOCATION,
  WORK_ZONE_TYPE,
  CONTRIBUTING_CIRC,
  ROUTE_TYPE,
  ROUTE_DIRECTION,
} from '../../../core/models/mmucc-lookup';

/** MMUCC crash severity codes (C3). */
const CRASH_SEVERITY: Record<number, string> = {
  1: 'Fatal (K)',
  2: 'Serious Injury (A)',
  3: 'Minor Injury (B)',
  4: 'Possible Injury (C)',
  5: 'No Apparent Injury / PDO (O)',
};

/** C10 – Source of Information. */
const SOURCE_OF_INFO: Record<number, string> = {
  1:  'Law Enforcement Report',
  2:  'Self Report / Citizen',
  3:  'EMS/Fire Report',
  4:  'Hospital/Medical Report',
  5:  'Other',
  9:  'Unknown',
};

/** C16 – Intersection Approaches. */
const INTERSECTION_APPROACHES: Record<number, string> = {
  3: '3 Approaches',
  4: '4 Approaches',
  5: '5 Approaches',
  6: '6 or More Approaches',
  9: 'Unknown',
};

/** C27 – Work Zone Workers Present. */
const WORK_ZONE_WORKERS: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

/** C27 – Law Enforcement in Work Zone. */
const WORK_ZONE_LAW_ENF: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

/** Day-of-week codes (1=Sun, 7=Sat). */
const DAY_OF_WEEK: Record<number, string> = {
  1: 'Sunday',
  2: 'Monday',
  3: 'Tuesday',
  4: 'Wednesday',
  5: 'Thursday',
  6: 'Friday',
  7: 'Saturday',
};

/** Ref-point direction codes. */
const REF_POINT_DIRECTION: Record<number, string> = {
  1: 'North',
  2: 'South',
  3: 'East',
  4: 'West',
  5: 'Northeast',
  6: 'Northwest',
  7: 'Southeast',
  8: 'Southwest',
};

/** Converts a Record<number,string> to sorted [code, label][] pairs. */
function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

@Component({
  selector: 'app-crash-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './crash-form.component.html',
  styleUrl: './crash-form.component.scss',
})
export class CrashFormComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly refSvc       = inject(ReferenceService);
  private readonly route        = inject(ActivatedRoute);
  private readonly router       = inject(Router);
  private readonly fb           = inject(FormBuilder);
  private readonly destroyRef   = inject(DestroyRef);

  // ── Signals ────────────────────────────────────────────────────────────────
  readonly loading  = signal(false);
  readonly saving   = signal(false);
  readonly errorMsg = signal('');

  readonly crashId = computed<number | null>(() => {
    const id = this.route.snapshot.paramMap.get('id');
    return id ? Number(id) : null;
  });

  readonly isEditMode = computed(() => this.crashId() != null);

  readonly pageTitle = computed(() =>
    this.isEditMode() ? 'Edit Crash' : 'New Crash'
  );

  // ── Multi-value selections (checkbox grids) ────────────────────────────────
  readonly selectedWeather     = signal<Set<number>>(new Set());
  readonly selectedSurface     = signal<Set<number>>(new Set());
  readonly selectedContrib     = signal<Set<number>>(new Set());

  // ── Lookup maps exposed to template ───────────────────────────────────────
  // 4 maps covered by reference-service: live data preferred, static fallback.
  readonly CRASH_TYPE_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.crashTypes();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(CRASH_TYPE_STATIC);
  });
  readonly HARMFUL_EVENT_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.harmfulEvents();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(HARMFUL_EVENT_STATIC);
  });
  readonly WEATHER_CONDITION_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.weatherConditions();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(WEATHER_CONDITION_STATIC);
  });
  readonly SURFACE_CONDITION_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.surfaceConditions();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(SURFACE_CONDITION_STATIC);
  });

  readonly MANNER_COLLISION_ENTRIES      = entries(MANNER_COLLISION);
  readonly LOC_FIRST_HARMFUL_EVENT_ENTRIES = entries(LOC_FIRST_HARMFUL_EVENT);
  readonly LIGHT_CONDITION_ENTRIES       = entries(LIGHT_CONDITION);
  readonly JUNCTION_TYPE_ENTRIES         = entries(JUNCTION_TYPE);
  readonly INTERSECTION_GEOMETRY_ENTRIES = entries(INTERSECTION_GEOMETRY);
  readonly INTERSECTION_TRAFFIC_CTL_ENTRIES = entries(INTERSECTION_TRAFFIC_CTL);
  readonly INTERSECTION_APPROACHES_ENTRIES  = entries(INTERSECTION_APPROACHES);
  readonly INVOLVEMENT_ENTRIES           = entries(INVOLVEMENT);
  readonly YES_NO_ENTRIES                = entries(YES_NO);
  readonly WORK_ZONE_LOCATION_ENTRIES    = entries(WORK_ZONE_LOCATION);
  readonly WORK_ZONE_TYPE_ENTRIES        = entries(WORK_ZONE_TYPE);
  readonly WORK_ZONE_WORKERS_ENTRIES     = entries(WORK_ZONE_WORKERS);
  readonly WORK_ZONE_LAW_ENF_ENTRIES     = entries(WORK_ZONE_LAW_ENF);
  readonly CONTRIBUTING_CIRC_ENTRIES     = entries(CONTRIBUTING_CIRC);
  readonly CRASH_SEVERITY_ENTRIES        = entries(CRASH_SEVERITY);
  readonly SOURCE_OF_INFO_ENTRIES        = entries(SOURCE_OF_INFO);
  readonly DAY_OF_WEEK_ENTRIES           = entries(DAY_OF_WEEK);
  readonly ROUTE_TYPE_ENTRIES            = entries(ROUTE_TYPE);
  readonly ROUTE_DIRECTION_ENTRIES       = entries(ROUTE_DIRECTION);
  readonly REF_POINT_DIRECTION_ENTRIES   = entries(REF_POINT_DIRECTION);

  // ── Form ──────────────────────────────────────────────────────────────────
  readonly form = this.fb.nonNullable.group({
    crashIdentifier:          [''],
    crashDate:                ['', Validators.required],
    crashTime:                [''],
    dayOfWeekCode:            [null as number | null],
    crashSeverityCode:        [null as number | null],
    sourceOfInfoCode:         [null as number | null],
    // Location
    countyFipsCode:           [''],
    countyName:               [''],
    cityPlaceCode:            [''],
    cityPlaceName:            [''],
    routeId:                  [''],
    routeTypeCode:            [null as number | null],
    routeDirectionCode:       [null as number | null],
    distanceFromRefMiles:     [null as number | null],
    refPointDirectionCode:    [null as number | null],
    latitude:                 [null as number | null],
    longitude:                [null as number | null],
    // Crash characteristics
    crashTypeCode:            [null as number | null],
    firstHarmfulEventCode:    [null as number | null],
    locFirstHarmfulEvent:     [null as number | null],
    mannerCollisionCode:      [null as number | null],
    lightConditionCode:       [null as number | null],
    // Junction & intersection
    junctionInterchangeFlg:   [null as number | null],
    junctionLocationCode:     [null as number | null],
    intersectionApproaches:   [null as number | null],
    intersectionGeometryCode: [null as number | null],
    intersectionTrafficCtl:   [null as number | null],
    // Work zone
    workZoneRelatedCode:      [null as number | null],
    workZoneLocationCode:     [null as number | null],
    workZoneTypeCode:         [null as number | null],
    workZoneWorkersCode:      [null as number | null],
    workZoneLawEnfCode:       [null as number | null],
    // Involvement
    alcoholInvolvementCode:   [null as number | null],
    drugInvolvementCode:      [null as number | null],
    schoolBusRelatedCode:     [null as number | null],
    // Counts
    numMotorVehicles:         [null as number | null],
    numMotorists:             [null as number | null],
    numNonMotorists:          [null as number | null],
    numNonFatallyInjured:     [null as number | null],
    numFatalities:            [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    const id = this.crashId();
    if (id == null) return;

    this.loading.set(true);
    this.crashService.getCrash(id)
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(
            err instanceof Error ? err.message : 'Failed to load crash record.'
          );
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(detail => {
        this.form.patchValue({
          crashIdentifier:          detail.crashIdentifier ?? '',
          crashDate:                detail.crashDate,
          crashTime:                detail.crashTime
            ? detail.crashTime.substring(0, 5)
            : '',
          dayOfWeekCode:            detail.dayOfWeekCode,
          crashSeverityCode:        detail.crashSeverityCode,
          sourceOfInfoCode:         detail.sourceOfInfoCode,
          countyFipsCode:           detail.countyFipsCode ?? '',
          countyName:               detail.countyName ?? '',
          cityPlaceCode:            detail.cityPlaceCode ?? '',
          cityPlaceName:            detail.cityPlaceName ?? '',
          routeId:                  detail.routeId ?? '',
          routeTypeCode:            detail.routeTypeCode,
          routeDirectionCode:       detail.routeDirectionCode,
          distanceFromRefMiles:     detail.distanceFromRefMiles,
          refPointDirectionCode:    detail.refPointDirectionCode,
          latitude:                 detail.latitude,
          longitude:                detail.longitude,
          crashTypeCode:            detail.crashTypeCode,
          firstHarmfulEventCode:    detail.firstHarmfulEventCode,
          locFirstHarmfulEvent:     detail.locFirstHarmfulEvent,
          mannerCollisionCode:      detail.mannerCollisionCode,
          lightConditionCode:       detail.lightConditionCode,
          junctionInterchangeFlg:   detail.junctionInterchangeFlg,
          junctionLocationCode:     detail.junctionLocationCode,
          intersectionApproaches:   detail.intersectionApproaches,
          intersectionGeometryCode: detail.intersectionGeometryCode,
          intersectionTrafficCtl:   detail.intersectionTrafficCtl,
          workZoneRelatedCode:      detail.workZoneRelatedCode,
          workZoneLocationCode:     detail.workZoneLocationCode,
          workZoneTypeCode:         detail.workZoneTypeCode,
          workZoneWorkersCode:      detail.workZoneWorkersCode,
          workZoneLawEnfCode:       detail.workZoneLawEnfCode,
          alcoholInvolvementCode:   detail.alcoholInvolvementCode,
          drugInvolvementCode:      detail.drugInvolvementCode,
          schoolBusRelatedCode:     detail.schoolBusRelatedCode,
          numMotorVehicles:         detail.numMotorVehicles,
          numMotorists:             detail.numMotorists,
          numNonMotorists:          detail.numNonMotorists,
          numNonFatallyInjured:     detail.numNonFatallyInjured,
          numFatalities:            detail.numFatalities,
        });
        this.selectedWeather.set(
          new Set(detail.weatherConditions.map(c => c.code))
        );
        this.selectedSurface.set(
          new Set(detail.surfaceConditions.map(c => c.code))
        );
        this.selectedContrib.set(
          new Set(detail.contributingCircumstances.map(c => c.code))
        );
        this.loading.set(false);
      });
  }

  // ── Checkbox toggle helpers ────────────────────────────────────────────────

  toggleWeather(code: number): void {
    this.selectedWeather.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  toggleSurface(code: number): void {
    this.selectedSurface.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  toggleContrib(code: number): void {
    this.selectedContrib.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.saving.set(true);
    this.errorMsg.set('');
    const request = this.buildRequest();
    const id = this.crashId();
    const op$ = id != null
      ? this.crashService.updateCrash(id, request)
      : this.crashService.createCrash(request);

    op$.pipe(
      catchError((err: unknown) => {
        this.errorMsg.set(
          err instanceof Error ? err.message : 'Failed to save crash record.'
        );
        this.saving.set(false);
        return EMPTY;
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(detail => {
      this.saving.set(false);
      this.router.navigate(['/crashes', detail.crashId]);
    });
  }

  onCancel(): void {
    const id = this.crashId();
    if (id != null) {
      this.router.navigate(['/crashes', id]);
    } else {
      this.router.navigate(['/crashes']);
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  private buildRequest(): CrashRequest {
    const raw = this.form.getRawValue();

    const toNum = (v: number | null | string): number | null => {
      if (v === null || v === '') return null;
      const n = Number(v);
      return isNaN(n) ? null : n;
    };

    const toStr = (v: string): string | null =>
      v.trim() === '' ? null : v.trim();

    const setToSeq = (s: Set<number>): { sequenceNum: number; code: number }[] =>
      Array.from(s)
        .sort((a, b) => a - b)
        .map((code, i) => ({ sequenceNum: i + 1, code }));

    return {
      crashIdentifier:          toStr(raw.crashIdentifier),
      crashDate:                raw.crashDate,
      crashTime:                toStr(raw.crashTime),
      dayOfWeekCode:            toNum(raw.dayOfWeekCode),
      crashSeverityCode:        toNum(raw.crashSeverityCode),
      sourceOfInfoCode:         toNum(raw.sourceOfInfoCode),
      countyFipsCode:           toStr(raw.countyFipsCode),
      countyName:               toStr(raw.countyName),
      cityPlaceCode:            toStr(raw.cityPlaceCode),
      cityPlaceName:            toStr(raw.cityPlaceName),
      routeId:                  toStr(raw.routeId),
      routeTypeCode:            toNum(raw.routeTypeCode),
      routeDirectionCode:       toNum(raw.routeDirectionCode),
      distanceFromRefMiles:     toNum(raw.distanceFromRefMiles),
      refPointDirectionCode:    toNum(raw.refPointDirectionCode),
      latitude:                 toNum(raw.latitude),
      longitude:                toNum(raw.longitude),
      crashTypeCode:            toNum(raw.crashTypeCode),
      firstHarmfulEventCode:    toNum(raw.firstHarmfulEventCode),
      locFirstHarmfulEvent:     toNum(raw.locFirstHarmfulEvent),
      mannerCollisionCode:      toNum(raw.mannerCollisionCode),
      lightConditionCode:       toNum(raw.lightConditionCode),
      junctionInterchangeFlg:   toNum(raw.junctionInterchangeFlg),
      junctionLocationCode:     toNum(raw.junctionLocationCode),
      intersectionApproaches:   toNum(raw.intersectionApproaches),
      intersectionGeometryCode: toNum(raw.intersectionGeometryCode),
      intersectionTrafficCtl:   toNum(raw.intersectionTrafficCtl),
      workZoneRelatedCode:      toNum(raw.workZoneRelatedCode),
      workZoneLocationCode:     toNum(raw.workZoneLocationCode),
      workZoneTypeCode:         toNum(raw.workZoneTypeCode),
      workZoneWorkersCode:      toNum(raw.workZoneWorkersCode),
      workZoneLawEnfCode:       toNum(raw.workZoneLawEnfCode),
      alcoholInvolvementCode:   toNum(raw.alcoholInvolvementCode),
      drugInvolvementCode:      toNum(raw.drugInvolvementCode),
      schoolBusRelatedCode:     toNum(raw.schoolBusRelatedCode),
      numMotorVehicles:         toNum(raw.numMotorVehicles),
      numMotorists:             toNum(raw.numMotorists),
      numNonMotorists:          toNum(raw.numNonMotorists),
      numNonFatallyInjured:     toNum(raw.numNonFatallyInjured),
      numFatalities:            toNum(raw.numFatalities),
      weatherConditions:        setToSeq(this.selectedWeather()),
      surfaceConditions:        setToSeq(this.selectedSurface()),
      contributingCircumstances: setToSeq(this.selectedContrib()),
    };
  }
}
