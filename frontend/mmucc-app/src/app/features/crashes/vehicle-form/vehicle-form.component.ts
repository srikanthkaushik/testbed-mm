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
import { VehicleRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import {
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
  HARMFUL_EVENT,
  YES_NO,
} from '../../../core/models/mmucc-lookup';

// V11 – Special Function Use
const SPECIAL_FUNCTION: Record<number, string> = {
  1: 'Not a Special Function Vehicle',
  2: 'Police/Law Enforcement',
  3: 'Fire',
  4: 'Ambulance/EMS',
  5: 'School Bus',
  6: 'Military',
  7: 'Taxi / Rideshare / TNC',
  8: 'Other Special Function',
  9: 'Unknown',
};

// V12 – Emergency Use
const EMERGENCY_USE: Record<number, string> = {
  1: 'Yes – Responding to Emergency',
  2: 'No',
  9: 'Unknown',
};

// Vehicle size designation (CMV)
const VEHICLE_SIZE: Record<number, string> = {
  1: 'Light (GVWR ≤ 10,000 lbs)',
  2: 'Medium/Heavy (GVWR > 10,000 lbs)',
  9: 'Unknown',
};

// HazMat placard flag
const HM_PLACARD: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

// Trafficway barrier / median barrier type
const TRAFFICWAY_BARRIER: Record<number, string> = {
  1: 'No Barrier',
  2: 'Barrier Present',
  9: 'Unknown',
};

// V24 – Hit and Run
const HIT_AND_RUN: Record<number, string> = {
  1: 'Yes',
  2: 'No',
  9: 'Unknown',
};

function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

@Component({
  selector: 'app-vehicle-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './vehicle-form.component.html',
  styleUrl: './vehicle-form.component.scss',
})
export class VehicleFormComponent implements OnInit {
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

  readonly vehicleId = computed<number | null>(() => {
    const id = this.route.snapshot.paramMap.get('vehicleId');
    return id ? Number(id) : null;
  });

  readonly isEditMode = computed(() => this.vehicleId() != null);

  readonly pageTitle = computed(() =>
    this.isEditMode() ? 'Edit Vehicle' : 'Add Vehicle'
  );

  // ── Multi-value selections ─────────────────────────────────────────────────
  readonly selectedTrafficControls = signal<Set<number>>(new Set());
  readonly selectedDamageAreas     = signal<Set<number>>(new Set());
  readonly selectedSequenceEvents  = signal<Set<number>>(new Set());

  // ── Lookup maps ───────────────────────────────────────────────────────────
  readonly UNIT_TYPE_ENTRIES             = entries(UNIT_TYPE);
  readonly BODY_TYPE_ENTRIES             = entries(BODY_TYPE);
  readonly TRAFFIC_CONTROL_ENTRIES       = entries(TRAFFIC_CONTROL);
  readonly DIRECTION_OF_TRAVEL_ENTRIES   = entries(DIRECTION_OF_TRAVEL);
  readonly TRAFFICWAY_TRAVEL_DIR_ENTRIES = entries(TRAFFICWAY_TRAVEL_DIR);
  readonly TRAFFICWAY_DIVIDED_ENTRIES    = entries(TRAFFICWAY_DIVIDED);
  readonly TRAFFICWAY_BARRIER_ENTRIES    = entries(TRAFFICWAY_BARRIER);
  readonly ROADWAY_ALIGNMENT_ENTRIES     = entries(ROADWAY_ALIGNMENT);
  readonly ROADWAY_GRADE_ENTRIES         = entries(ROADWAY_GRADE);
  readonly MANEUVER_ENTRIES              = entries(MANEUVER);
  readonly DAMAGE_EXTENT_ENTRIES         = entries(DAMAGE_EXTENT);
  readonly TOWED_ENTRIES                 = entries(TOWED);
  readonly DAMAGE_AREA_ENTRIES           = entries(DAMAGE_AREA);
  readonly CONTRIBUTING_CIRC_ENTRIES     = entries(CONTRIBUTING_CIRC);
  readonly HARMFUL_EVENT_ENTRIES         = entries(HARMFUL_EVENT);
  readonly YES_NO_ENTRIES                = entries(YES_NO);
  readonly SPECIAL_FUNCTION_ENTRIES      = entries(SPECIAL_FUNCTION);
  readonly EMERGENCY_USE_ENTRIES         = entries(EMERGENCY_USE);
  readonly VEHICLE_SIZE_ENTRIES          = entries(VEHICLE_SIZE);
  readonly HM_PLACARD_ENTRIES            = entries(HM_PLACARD);
  readonly HIT_AND_RUN_ENTRIES           = entries(HIT_AND_RUN);

  // ── Form ──────────────────────────────────────────────────────────────────
  readonly form = this.fb.nonNullable.group({
    // Identification
    unitTypeCode:      [null as number | null],
    unitNumber:        [null as number | null],
    vin:               [''],
    registrationState: [''],
    registrationYear:  [null as number | null],
    licensePlate:      [''],
    // Vehicle description
    make:              [''],
    model:             [''],
    modelYear:         [null as number | null],
    bodyTypeCode:      [null as number | null],
    // Classification
    vehicleSizeCode:   [null as number | null],
    hmPlacardFlg:      [null as number | null],
    trailingUnitsCount: [null as number | null],
    totalOccupants:    [null as number | null],
    specialFunctionCode: [null as number | null],
    emergencyUseCode:  [null as number | null],
    // Pre-crash / roadway
    speedLimitMph:           [null as number | null],
    directionOfTravelCode:   [null as number | null],
    trafficwayTravelDirCode: [null as number | null],
    trafficwayDividedCode:   [null as number | null],
    trafficwayBarrierCode:   [null as number | null],
    trafficwayHovHotCode:    [null as number | null],
    trafficwayHovCrashFlg:   [null as number | null],
    totalThroughLanes:       [null as number | null],
    totalAuxiliaryLanes:     [null as number | null],
    roadwayAlignmentCode:    [null as number | null],
    roadwayGradeCode:        [null as number | null],
    maneuverCode:            [null as number | null],
    // Crash events
    mostHarmfulEventCode: [null as number | null],
    // Damage
    damageInitialContact: [null as number | null],
    damageExtentCode:     [null as number | null],
    // Post-crash
    hitAndRunCode:        [null as number | null],
    towedCode:            [null as number | null],
    contributingCircCode: [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    const vid = this.vehicleId();
    if (vid == null) return;

    this.loading.set(true);
    this.crashService.getVehicle(this.crashId(), vid)
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(
            err instanceof Error ? err.message : 'Failed to load vehicle record.'
          );
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(v => {
        this.form.patchValue({
          unitTypeCode:      v.unitTypeCode,
          unitNumber:        v.unitNumber,
          vin:               v.vin ?? '',
          registrationState: v.registrationState ?? '',
          registrationYear:  v.registrationYear,
          licensePlate:      v.licensePlate ?? '',
          make:              v.make ?? '',
          model:             v.model ?? '',
          modelYear:         v.modelYear,
          bodyTypeCode:      v.bodyTypeCode,
          vehicleSizeCode:   v.vehicleSizeCode,
          hmPlacardFlg:      v.hmPlacardFlg,
          trailingUnitsCount: v.trailingUnitsCount,
          totalOccupants:    v.totalOccupants,
          specialFunctionCode: v.specialFunctionCode,
          emergencyUseCode:  v.emergencyUseCode,
          speedLimitMph:           v.speedLimitMph,
          directionOfTravelCode:   v.directionOfTravelCode,
          trafficwayTravelDirCode: v.trafficwayTravelDirCode,
          trafficwayDividedCode:   v.trafficwayDividedCode,
          trafficwayBarrierCode:   v.trafficwayBarrierCode,
          trafficwayHovHotCode:    v.trafficwayHovHotCode,
          trafficwayHovCrashFlg:   v.trafficwayHovCrashFlg,
          totalThroughLanes:       v.totalThroughLanes,
          totalAuxiliaryLanes:     v.totalAuxiliaryLanes,
          roadwayAlignmentCode:    v.roadwayAlignmentCode,
          roadwayGradeCode:        v.roadwayGradeCode,
          maneuverCode:            v.maneuverCode,
          mostHarmfulEventCode: v.mostHarmfulEventCode,
          damageInitialContact: v.damageInitialContact,
          damageExtentCode:     v.damageExtentCode,
          hitAndRunCode:        v.hitAndRunCode,
          towedCode:            v.towedCode,
          contributingCircCode: v.contributingCircCode,
        });

        // Restore multi-value sets — trafficControls uses trafficControlCode on the detail model
        this.selectedTrafficControls.set(
          new Set(v.trafficControls.map(tc => tc.trafficControlCode))
        );
        this.selectedDamageAreas.set(
          new Set(v.damageAreas.map(d => d.code))
        );
        this.selectedSequenceEvents.set(
          new Set(v.sequenceEvents.map(e => e.code))
        );
        this.loading.set(false);
      });
  }

  // ── Toggle helpers ─────────────────────────────────────────────────────────

  toggleTrafficControl(code: number): void {
    this.selectedTrafficControls.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  toggleDamageArea(code: number): void {
    this.selectedDamageAreas.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  toggleSequenceEvent(code: number): void {
    this.selectedSequenceEvents.update(s => {
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
    const crashId = this.crashId();
    const vid = this.vehicleId();

    const op$ = vid != null
      ? this.crashService.updateVehicle(crashId, vid, request)
      : this.crashService.createVehicle(crashId, request);

    op$.pipe(
      catchError((err: unknown) => {
        this.errorMsg.set(
          err instanceof Error ? err.message : 'Failed to save vehicle record.'
        );
        this.saving.set(false);
        return EMPTY;
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(() => {
      this.saving.set(false);
      this.router.navigate(['/crashes', crashId], { fragment: 'vehicles' });
    });
  }

  onCancel(): void {
    this.router.navigate(['/crashes', this.crashId()], { fragment: 'vehicles' });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  private buildRequest(): VehicleRequest {
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

    const tcArray = Array.from(this.selectedTrafficControls())
      .sort((a, b) => a - b)
      .map((code, i) => ({ sequenceNum: i + 1, tcdTypeCode: code, tcdInoperativeCode: null }));

    return {
      vin:               toStr(raw.vin),
      unitTypeCode:      toNum(raw.unitTypeCode),
      unitNumber:        toNum(raw.unitNumber),
      registrationState: toStr(raw.registrationState),
      registrationYear:  toNum(raw.registrationYear),
      licensePlate:      toStr(raw.licensePlate),
      make:              toStr(raw.make),
      modelYear:         toNum(raw.modelYear),
      model:             toStr(raw.model),
      bodyTypeCode:      toNum(raw.bodyTypeCode),
      trailingUnitsCount: toNum(raw.trailingUnitsCount),
      vehicleSizeCode:   toNum(raw.vehicleSizeCode),
      hmPlacardFlg:      toNum(raw.hmPlacardFlg),
      totalOccupants:    toNum(raw.totalOccupants),
      specialFunctionCode: toNum(raw.specialFunctionCode),
      emergencyUseCode:  toNum(raw.emergencyUseCode),
      speedLimitMph:           toNum(raw.speedLimitMph),
      directionOfTravelCode:   toNum(raw.directionOfTravelCode),
      trafficwayTravelDirCode: toNum(raw.trafficwayTravelDirCode),
      trafficwayDividedCode:   toNum(raw.trafficwayDividedCode),
      trafficwayBarrierCode:   toNum(raw.trafficwayBarrierCode),
      trafficwayHovHotCode:    toNum(raw.trafficwayHovHotCode),
      trafficwayHovCrashFlg:   toNum(raw.trafficwayHovCrashFlg),
      totalThroughLanes:       toNum(raw.totalThroughLanes),
      totalAuxiliaryLanes:     toNum(raw.totalAuxiliaryLanes),
      roadwayAlignmentCode:    toNum(raw.roadwayAlignmentCode),
      roadwayGradeCode:        toNum(raw.roadwayGradeCode),
      maneuverCode:            toNum(raw.maneuverCode),
      damageInitialContact: toNum(raw.damageInitialContact),
      damageExtentCode:     toNum(raw.damageExtentCode),
      mostHarmfulEventCode: toNum(raw.mostHarmfulEventCode),
      hitAndRunCode:        toNum(raw.hitAndRunCode),
      towedCode:            toNum(raw.towedCode),
      contributingCircCode: toNum(raw.contributingCircCode),
      trafficControls: tcArray,
      damageAreas:     setToSeq(this.selectedDamageAreas()),
      sequenceEvents:  setToSeq(this.selectedSequenceEvents()),
    };
  }
}
