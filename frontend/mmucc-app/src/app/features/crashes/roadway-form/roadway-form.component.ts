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
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { catchError } from 'rxjs/operators';
import { EMPTY } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { RoadwayRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import {
  FUNCTIONAL_CLASS,
  ACCESS_CONTROL,
  ROADWAY_LIGHTING,
  PAVEMENT_CENTERLINE,
  PAVEMENT_EDGELINE,
  PAVEMENT_LANE_LINE,
  BICYCLE_FACILITY,
  BICYCLE_SIGNED_ROUTE,
  YES_NO,
} from '../../../core/models/mmucc-lookup';

// R3 – Grade Direction coded values
const GRADE_DIRECTION: Record<string, string> = {
  U: 'Upgrade',
  D: 'Downgrade',
  L: 'Level (0%)',
  V: 'Variable',
};

function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

function strEntries(map: Record<string, string>): [string, string][] {
  return Object.entries(map);
}

@Component({
  selector: 'app-roadway-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './roadway-form.component.html',
  styleUrl: './roadway-form.component.scss',
})
export class RoadwayFormComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly route        = inject(ActivatedRoute);
  private readonly router       = inject(Router);
  private readonly fb           = inject(FormBuilder);
  private readonly destroyRef   = inject(DestroyRef);

  // ── Signals ────────────────────────────────────────────────────────────────
  readonly loading  = signal(false);
  readonly saving   = signal(false);
  readonly errorMsg = signal('');

  readonly crashId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('crashId'))
  );

  // Roadway is always upsert — no separate "new" vs "edit" mode.
  // Page title reflects whether data existed on load.
  readonly hasExisting = signal(false);
  readonly pageTitle   = computed(() =>
    this.hasExisting() ? 'Edit Roadway' : 'Add Roadway'
  );

  // ── Lookup entries ─────────────────────────────────────────────────────────
  readonly FUNCTIONAL_CLASS_ENTRIES    = entries(FUNCTIONAL_CLASS);
  readonly ACCESS_CONTROL_ENTRIES      = entries(ACCESS_CONTROL);
  readonly ROADWAY_LIGHTING_ENTRIES    = entries(ROADWAY_LIGHTING);
  readonly PAVEMENT_CENTERLINE_ENTRIES = entries(PAVEMENT_CENTERLINE);
  readonly PAVEMENT_EDGELINE_ENTRIES   = entries(PAVEMENT_EDGELINE);
  readonly PAVEMENT_LANE_LINE_ENTRIES  = entries(PAVEMENT_LANE_LINE);
  readonly BICYCLE_FACILITY_ENTRIES    = entries(BICYCLE_FACILITY);
  readonly BICYCLE_SIGNED_ROUTE_ENTRIES = entries(BICYCLE_SIGNED_ROUTE);
  readonly YES_NO_ENTRIES              = entries(YES_NO);
  readonly GRADE_DIRECTION_ENTRIES     = strEntries(GRADE_DIRECTION);

  // ── Form ──────────────────────────────────────────────────────────────────
  readonly form = this.fb.nonNullable.group({
    // Classification (R4, R5, R9)
    nationalHwySysCode:     [null as number | null],
    functionalClassCode:    [null as number | null],
    accessControlCode:      [null as number | null],
    // Physical geometry (R1–R3, R7, R8)
    bridgeStructureId:      ['' as string],
    curveRadiusFt:          [null as number | null],
    curveLengthFt:          [null as number | null],
    curveSuperelevationPct: [null as number | null],
    gradeDirection:         ['' as string],
    gradePercent:           [null as number | null],
    laneWidthFt:            [null as number | null],
    leftShoulderWidthFt:    [null as number | null],
    rightShoulderWidthFt:   [null as number | null],
    medianWidthFt:          [null as number | null],
    // Traffic volume (R6, R14–R16)
    aadtYear:               [null as number | null],
    aadtValue:              [null as number | null],
    aadtTruckMeasure:       ['' as string],
    aadtMotorcycleMeasure:  ['' as string],
    mainlineLanesCount:     [null as number | null],
    crossStreetLanesCount:  [null as number | null],
    enteringVehiclesYear:   [null as number | null],
    enteringVehiclesAadt:   [null as number | null],
    // Infrastructure (R10–R12)
    railwayCrossingId:      ['' as string],
    roadwayLightingCode:    [null as number | null],
    pavementEdgelineCode:   [null as number | null],
    pavementCenterlineCode: [null as number | null],
    pavementLaneLineCode:   [null as number | null],
    // Bicycle (R13)
    bicycleFacilityCode:    [null as number | null],
    bicycleSignedRouteCode: [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    this.loading.set(true);
    this.crashService.getRoadway(this.crashId())
      .pipe(
        catchError(() => {
          // 404 = no roadway yet; start with blank form — not an error
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(r => {
        this.hasExisting.set(true);
        this.form.patchValue({
          nationalHwySysCode:     r.nationalHwySysCode,
          functionalClassCode:    r.functionalClassCode,
          accessControlCode:      r.accessControlCode,
          bridgeStructureId:      r.bridgeStructureId ?? '',
          curveRadiusFt:          r.curveRadiusFt,
          curveLengthFt:          r.curveLengthFt,
          curveSuperelevationPct: r.curveSuperelevationPct,
          gradeDirection:         r.gradeDirection ?? '',
          gradePercent:           r.gradePercent,
          laneWidthFt:            r.laneWidthFt,
          leftShoulderWidthFt:    r.leftShoulderWidthFt,
          rightShoulderWidthFt:   r.rightShoulderWidthFt,
          medianWidthFt:          r.medianWidthFt,
          aadtYear:               r.aadtYear,
          aadtValue:              r.aadtValue,
          aadtTruckMeasure:       r.aadtTruckMeasure ?? '',
          aadtMotorcycleMeasure:  r.aadtMotorcycleMeasure ?? '',
          mainlineLanesCount:     r.mainlineLanesCount,
          crossStreetLanesCount:  r.crossStreetLanesCount,
          enteringVehiclesYear:   r.enteringVehiclesYear,
          enteringVehiclesAadt:   r.enteringVehiclesAadt,
          railwayCrossingId:      r.railwayCrossingId ?? '',
          roadwayLightingCode:    r.roadwayLightingCode,
          pavementEdgelineCode:   r.pavementEdgelineCode,
          pavementCenterlineCode: r.pavementCenterlineCode,
          pavementLaneLineCode:   r.pavementLaneLineCode,
          bicycleFacilityCode:    r.bicycleFacilityCode,
          bicycleSignedRouteCode: r.bicycleSignedRouteCode,
        });
        this.loading.set(false);
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

    this.crashService.upsertRoadway(this.crashId(), this.buildRequest())
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(err instanceof Error ? err.message : 'Failed to save roadway.');
          this.saving.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => {
        this.saving.set(false);
        this.router.navigate(['/crashes', this.crashId()], { fragment: 'roadway' });
      });
  }

  onCancel(): void {
    this.router.navigate(['/crashes', this.crashId()], { fragment: 'roadway' });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  private buildRequest(): RoadwayRequest {
    const raw = this.form.getRawValue();

    const toNum = (v: number | null): number | null => {
      if (v === null) return null;
      const n = Number(v);
      return isNaN(n) ? null : n;
    };

    const toStr = (v: string): string | null =>
      v.trim() === '' ? null : v.trim();

    return {
      bridgeStructureId:        toStr(raw.bridgeStructureId),
      curveRadiusFt:            toNum(raw.curveRadiusFt),
      curveLengthFt:            toNum(raw.curveLengthFt),
      curveSuperelevationPct:   toNum(raw.curveSuperelevationPct),
      gradeDirection:           toStr(raw.gradeDirection),
      gradePercent:             toNum(raw.gradePercent),
      nationalHwySysCode:       toNum(raw.nationalHwySysCode),
      functionalClassCode:      toNum(raw.functionalClassCode),
      aadtYear:                 toNum(raw.aadtYear),
      aadtValue:                toNum(raw.aadtValue),
      aadtTruckMeasure:         toStr(raw.aadtTruckMeasure),
      aadtMotorcycleMeasure:    toStr(raw.aadtMotorcycleMeasure),
      laneWidthFt:              toNum(raw.laneWidthFt),
      leftShoulderWidthFt:      toNum(raw.leftShoulderWidthFt),
      rightShoulderWidthFt:     toNum(raw.rightShoulderWidthFt),
      medianWidthFt:            toNum(raw.medianWidthFt),
      accessControlCode:        toNum(raw.accessControlCode),
      railwayCrossingId:        toStr(raw.railwayCrossingId),
      roadwayLightingCode:      toNum(raw.roadwayLightingCode),
      pavementEdgelineCode:     toNum(raw.pavementEdgelineCode),
      pavementCenterlineCode:   toNum(raw.pavementCenterlineCode),
      pavementLaneLineCode:     toNum(raw.pavementLaneLineCode),
      bicycleFacilityCode:      toNum(raw.bicycleFacilityCode),
      bicycleSignedRouteCode:   toNum(raw.bicycleSignedRouteCode),
      mainlineLanesCount:       toNum(raw.mainlineLanesCount),
      crossStreetLanesCount:    toNum(raw.crossStreetLanesCount),
      enteringVehiclesYear:     toNum(raw.enteringVehiclesYear),
      enteringVehiclesAadt:     toNum(raw.enteringVehiclesAadt),
    };
  }
}
