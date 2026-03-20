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
import { VehicleAutomationRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import { AUTOMATION_PRESENT, AUTOMATION_LEVEL } from '../../../core/models/mmucc-lookup';

function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

@Component({
  selector: 'app-vehicle-automation-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './vehicle-automation-form.component.html',
  styleUrl: './vehicle-automation-form.component.scss',
})
export class VehicleAutomationFormComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly route        = inject(ActivatedRoute);
  private readonly router       = inject(Router);
  private readonly fb           = inject(FormBuilder);
  private readonly destroyRef   = inject(DestroyRef);

  // ── Signals ────────────────────────────────────────────────────────────────
  readonly loading  = signal(false);
  readonly saving   = signal(false);
  readonly errorMsg = signal('');

  readonly crashId   = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('crashId'))
  );
  readonly vehicleId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('vehicleId'))
  );

  // Single upsert route — title reflects whether data existed on load.
  readonly hasExisting = signal(false);
  readonly pageTitle   = computed(() =>
    this.hasExisting() ? 'Edit Automation (DV1)' : 'Add Automation (DV1)'
  );

  // ── Multi-value sets (checkbox grids) ──────────────────────────────────────
  readonly selectedInVehicle = signal<Set<number>>(new Set());
  readonly selectedEngaged   = signal<Set<number>>(new Set());

  // ── Lookup entries ─────────────────────────────────────────────────────────
  readonly AUTOMATION_PRESENT_ENTRIES = entries(AUTOMATION_PRESENT);
  readonly AUTOMATION_LEVEL_ENTRIES   = entries(AUTOMATION_LEVEL);

  // ── Form (only the scalar field; multi-value handled by signals) ───────────
  readonly form = this.fb.nonNullable.group({
    automationPresentCode: [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    this.loading.set(true);
    this.crashService.getAutomation(this.crashId(), this.vehicleId())
      .pipe(
        catchError(() => {
          // 404 = no automation record yet; start with blank form — not an error
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(a => {
        this.hasExisting.set(true);
        this.form.patchValue({ automationPresentCode: a.automationPresentCode });
        this.selectedInVehicle.set(new Set(a.levelsInVehicle.map(l => l.code)));
        this.selectedEngaged.set(new Set(a.levelsEngaged.map(l => l.code)));
        this.loading.set(false);
      });
  }

  // ── Checkbox toggle helpers ────────────────────────────────────────────────

  toggleInVehicle(code: number): void {
    this.selectedInVehicle.update(s => {
      const next = new Set(s);
      next.has(code) ? next.delete(code) : next.add(code);
      return next;
    });
  }

  toggleEngaged(code: number): void {
    this.selectedEngaged.update(s => {
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

    this.crashService.upsertAutomation(this.crashId(), this.vehicleId(), this.buildRequest())
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(err instanceof Error ? err.message : 'Failed to save automation record.');
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

  // ── Private helpers ────────────────────────────────────────────────────────

  private buildRequest(): VehicleAutomationRequest {
    const raw = this.form.getRawValue();

    const toNum = (v: number | null): number | null => {
      if (v === null) return null;
      const n = Number(v);
      return isNaN(n) ? null : n;
    };

    const setToSeq = (s: Set<number>) =>
      Array.from(s).sort((a, b) => a - b).map((code, i) => ({ sequenceNum: i + 1, code }));

    return {
      automationPresentCode: toNum(raw.automationPresentCode),
      levelsInVehicle:       setToSeq(this.selectedInVehicle()),
      levelsEngaged:         setToSeq(this.selectedEngaged()),
    };
  }
}
