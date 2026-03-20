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
import { LargeVehicleRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import {
  CMV_LICENSE_STATUS,
  CDL_COMPLIANCE,
  CARRIER_ID_TYPE,
  CARRIER_TYPE,
  VEHICLE_CONFIG,
  VEHICLE_PERMITTED,
  CARGO_BODY_TYPE,
  HM_RELEASED,
  LV_SPECIAL_SIZING,
} from '../../../core/models/mmucc-lookup';

function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

@Component({
  selector: 'app-large-vehicle-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './large-vehicle-form.component.html',
  styleUrl: './large-vehicle-form.component.scss',
})
export class LargeVehicleFormComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly route        = inject(ActivatedRoute);
  private readonly router       = inject(Router);
  private readonly fb           = inject(FormBuilder);
  private readonly destroyRef   = inject(DestroyRef);

  // ── Signals ───────────────────────────────────────────────────────────────
  readonly loading  = signal(false);
  readonly saving   = signal(false);
  readonly errorMsg = signal('');

  readonly crashId   = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('crashId'))
  );
  readonly vehicleId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('vehicleId'))
  );

  readonly hasExisting = signal(false);
  readonly pageTitle   = computed(() =>
    this.hasExisting() ? 'Edit Large Vehicle (LV1–LV11)' : 'Add Large Vehicle (LV1–LV11)'
  );

  // ── LV11: Special Sizing (checkbox grid) ──────────────────────────────────
  readonly selectedSpecialSizing = signal<Set<number>>(new Set());

  // ── Lookup entries ────────────────────────────────────────────────────────
  readonly CMV_LICENSE_STATUS_ENTRIES = entries(CMV_LICENSE_STATUS);
  readonly CDL_COMPLIANCE_ENTRIES     = entries(CDL_COMPLIANCE);
  readonly CARRIER_ID_TYPE_ENTRIES    = entries(CARRIER_ID_TYPE);
  readonly CARRIER_TYPE_ENTRIES       = entries(CARRIER_TYPE);
  readonly VEHICLE_CONFIG_ENTRIES     = entries(VEHICLE_CONFIG);
  readonly VEHICLE_PERMITTED_ENTRIES  = entries(VEHICLE_PERMITTED);
  readonly CARGO_BODY_TYPE_ENTRIES    = entries(CARGO_BODY_TYPE);
  readonly HM_RELEASED_ENTRIES        = entries(HM_RELEASED);
  readonly LV_SPECIAL_SIZING_ENTRIES  = entries(LV_SPECIAL_SIZING);

  // ── Form ──────────────────────────────────────────────────────────────────
  readonly form = this.fb.nonNullable.group({
    // LV1
    cmvLicenseStatusCode:  [null as number | null],
    cdlComplianceCode:     [null as number | null],
    // LV2 – Trailers
    trailer1Plate:  [null as string | null],
    trailer2Plate:  [null as string | null],
    trailer3Plate:  [null as string | null],
    trailer1Vin:    [null as string | null],
    trailer2Vin:    [null as string | null],
    trailer3Vin:    [null as string | null],
    trailer1Make:   [null as string | null],
    trailer2Make:   [null as string | null],
    trailer3Make:   [null as string | null],
    trailer1Model:  [null as string | null],
    trailer2Model:  [null as string | null],
    trailer3Model:  [null as string | null],
    trailer1Year:   [null as number | null],
    trailer2Year:   [null as number | null],
    trailer3Year:   [null as number | null],
    // LV3 – Motor Carrier
    carrierIdTypeCode:   [null as number | null],
    carrierCountryState: [null as string | null],
    carrierIdNumber:     [null as string | null],
    carrierName:         [null as string | null],
    carrierStreet1:      [null as string | null],
    carrierStreet2:      [null as string | null],
    carrierCity:         [null as string | null],
    carrierState:        [null as string | null],
    carrierZip:          [null as string | null],
    carrierCountry:      [null as string | null],
    // LV4
    carrierTypeCode:     [null as number | null],
    // LV5
    vehicleConfigCode:   [null as number | null],
    // LV6
    vehiclePermittedCode:[null as number | null],
    // LV7
    cargoBodyTypeCode:   [null as number | null],
    // LV8 – HazMat
    hmId:    [null as string | null],
    hmClass: [null as string | null],
    // LV9
    hmReleasedCode: [null as number | null],
    // LV10 – Axles
    axlesTractor:  [null as number | null],
    axlesTrailer1: [null as number | null],
    axlesTrailer2: [null as number | null],
    axlesTrailer3: [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    this.loading.set(true);
    this.crashService.getLargeVehicle(this.crashId(), this.vehicleId())
      .pipe(
        catchError(() => {
          // 404 = no LV record yet; start with blank form
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(lv => {
        this.hasExisting.set(true);
        this.form.patchValue({
          cmvLicenseStatusCode:  lv.cmvLicenseStatusCode,
          cdlComplianceCode:     lv.cdlComplianceCode,
          trailer1Plate:  lv.trailer1Plate,
          trailer2Plate:  lv.trailer2Plate,
          trailer3Plate:  lv.trailer3Plate,
          trailer1Vin:    lv.trailer1Vin,
          trailer2Vin:    lv.trailer2Vin,
          trailer3Vin:    lv.trailer3Vin,
          trailer1Make:   lv.trailer1Make,
          trailer2Make:   lv.trailer2Make,
          trailer3Make:   lv.trailer3Make,
          trailer1Model:  lv.trailer1Model,
          trailer2Model:  lv.trailer2Model,
          trailer3Model:  lv.trailer3Model,
          trailer1Year:   lv.trailer1Year,
          trailer2Year:   lv.trailer2Year,
          trailer3Year:   lv.trailer3Year,
          carrierIdTypeCode:   lv.carrierIdTypeCode,
          carrierCountryState: lv.carrierCountryState,
          carrierIdNumber:     lv.carrierIdNumber,
          carrierName:         lv.carrierName,
          carrierStreet1:      lv.carrierStreet1,
          carrierStreet2:      lv.carrierStreet2,
          carrierCity:         lv.carrierCity,
          carrierState:        lv.carrierState,
          carrierZip:          lv.carrierZip,
          carrierCountry:      lv.carrierCountry,
          carrierTypeCode:     lv.carrierTypeCode,
          vehicleConfigCode:   lv.vehicleConfigCode,
          vehiclePermittedCode:lv.vehiclePermittedCode,
          cargoBodyTypeCode:   lv.cargoBodyTypeCode,
          hmId:           lv.hmId,
          hmClass:        lv.hmClass,
          hmReleasedCode: lv.hmReleasedCode,
          axlesTractor:   lv.axlesTractor,
          axlesTrailer1:  lv.axlesTrailer1,
          axlesTrailer2:  lv.axlesTrailer2,
          axlesTrailer3:  lv.axlesTrailer3,
        });
        this.selectedSpecialSizing.set(new Set(lv.specialSizing.map(s => s.code)));
        this.loading.set(false);
      });
  }

  // ── Checkbox toggle ───────────────────────────────────────────────────────

  toggleSpecialSizing(code: number): void {
    this.selectedSpecialSizing.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.saving.set(true);
    this.errorMsg.set('');

    this.crashService.upsertLargeVehicle(this.crashId(), this.vehicleId(), this.buildRequest())
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(err instanceof Error ? err.message : 'Failed to save large vehicle record.');
          this.saving.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => {
        this.saving.set(false);
        this.router.navigate(['/crashes', this.crashId()], { fragment: 'vehicles' });
      });
  }

  onCancel(): void {
    this.router.navigate(['/crashes', this.crashId()], { fragment: 'vehicles' });
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  private buildRequest(): LargeVehicleRequest {
    const raw = this.form.getRawValue();

    const toNum = (v: number | string | null): number | null => {
      if (v === null || v === '') return null;
      const n = Number(v);
      return isNaN(n) ? null : n;
    };
    const toStr = (v: string | null): string | null =>
      v === '' ? null : v;

    return {
      cmvLicenseStatusCode:  toNum(raw.cmvLicenseStatusCode),
      cdlComplianceCode:     toNum(raw.cdlComplianceCode),
      trailer1Plate:  toStr(raw.trailer1Plate),
      trailer2Plate:  toStr(raw.trailer2Plate),
      trailer3Plate:  toStr(raw.trailer3Plate),
      trailer1Vin:    toStr(raw.trailer1Vin),
      trailer2Vin:    toStr(raw.trailer2Vin),
      trailer3Vin:    toStr(raw.trailer3Vin),
      trailer1Make:   toStr(raw.trailer1Make),
      trailer2Make:   toStr(raw.trailer2Make),
      trailer3Make:   toStr(raw.trailer3Make),
      trailer1Model:  toStr(raw.trailer1Model),
      trailer2Model:  toStr(raw.trailer2Model),
      trailer3Model:  toStr(raw.trailer3Model),
      trailer1Year:   toNum(raw.trailer1Year),
      trailer2Year:   toNum(raw.trailer2Year),
      trailer3Year:   toNum(raw.trailer3Year),
      carrierIdTypeCode:   toNum(raw.carrierIdTypeCode),
      carrierCountryState: toStr(raw.carrierCountryState),
      carrierIdNumber:     toStr(raw.carrierIdNumber),
      carrierName:         toStr(raw.carrierName),
      carrierStreet1:      toStr(raw.carrierStreet1),
      carrierStreet2:      toStr(raw.carrierStreet2),
      carrierCity:         toStr(raw.carrierCity),
      carrierState:        toStr(raw.carrierState),
      carrierZip:          toStr(raw.carrierZip),
      carrierCountry:      toStr(raw.carrierCountry),
      carrierTypeCode:     toNum(raw.carrierTypeCode),
      vehicleConfigCode:   toNum(raw.vehicleConfigCode),
      vehiclePermittedCode:toNum(raw.vehiclePermittedCode),
      cargoBodyTypeCode:   toNum(raw.cargoBodyTypeCode),
      hmId:    toStr(raw.hmId),
      hmClass: toStr(raw.hmClass),
      hmReleasedCode: toNum(raw.hmReleasedCode),
      axlesTractor:   toNum(raw.axlesTractor),
      axlesTrailer1:  toNum(raw.axlesTrailer1),
      axlesTrailer2:  toNum(raw.axlesTrailer2),
      axlesTrailer3:  toNum(raw.axlesTrailer3),
      specialSizing:  Array.from(this.selectedSpecialSizing())
        .sort((a, b) => a - b)
        .map((code, i) => ({ sequenceNum: i + 1, code })),
    };
  }
}
