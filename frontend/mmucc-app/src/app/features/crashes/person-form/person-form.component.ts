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
import { catchError, map, switchMap } from 'rxjs/operators';
import { EMPTY, Observable, forkJoin, of } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { ReferenceService } from '../../../core/services/reference.service';
import { FatalSectionRequest, NonMotoristRequest, PersonRequest } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';
import {
  SEX_CODE,
  PERSON_TYPE         as PERSON_TYPE_STATIC,
  INCIDENT_RESPONDER,
  INJURY_STATUS       as INJURY_STATUS_STATIC,
  SEATING_ROW,
  SEATING_SEAT,
  RESTRAINT,
  YES_NO,
  EJECTION,
  AIRBAG,
  DL_JURISDICTION_TYPE,
  DL_CLASS,
  DL_ENDORSEMENT,
  DL_RESTRICTION,
  DL_STATUS_TYPE,
  DL_STATUS,
  SPEEDING,
  DRIVER_ACTION,
  DISTRACTED_ACTION,
  DISTRACTED_SOURCE,
  DRIVER_CONDITION,
  ALCOHOL_TEST_STATUS,
  ALCOHOL_TEST_TYPE,
  DRUG_TEST_STATUS,
  DRUG_TEST_TYPE,
  DRUG_TEST_RESULT,
  TRANSPORT_SOURCE,
  INJURY_AREA,
  INJURY_SEVERITY,
  MANEUVER,
  NM_ACTION_CIRC,
  NM_ORIGIN_DESTINATION,
  NM_CONTRIBUTING_ACTION,
  NM_LOCATION_AT_CRASH,
  NM_CONTACT_POINT,
  NM_SAFETY_EQUIPMENT,
} from '../../../core/models/mmucc-lookup';

function entries(map: Record<number, string>): [number, string][] {
  return Object.entries(map).map(([k, v]) => [Number(k), v]);
}

// Non-motorist person type codes
const NM_PERSON_TYPES = new Set([5, 6, 7, 8, 9]);

@Component({
  selector: 'app-person-form',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './person-form.component.html',
  styleUrl: './person-form.component.scss',
})
export class PersonFormComponent implements OnInit {
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

  readonly crashId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('crashId'))
  );

  readonly vehicleId = computed<number>(() =>
    Number(this.route.snapshot.paramMap.get('vehicleId'))
  );

  readonly personId = computed<number | null>(() => {
    const id = this.route.snapshot.paramMap.get('personId');
    return id ? Number(id) : null;
  });

  readonly isEditMode = computed(() => this.personId() != null);

  readonly pageTitle = computed(() =>
    this.isEditMode() ? 'Edit Person' : 'Add Person'
  );

  // ── Multi-value selections ─────────────────────────────────────────────────
  readonly selectedAirbags        = signal<Set<number>>(new Set());
  readonly selectedDriverActions  = signal<Set<number>>(new Set());
  readonly selectedDlRestrictions = signal<Set<number>>(new Set());
  readonly selectedDrugResults    = signal<Set<number>>(new Set());
  readonly selectedNmSafetyEquip  = signal<Set<number>>(new Set());

  // ── Conditional display ────────────────────────────────────────────────────
  readonly isDriver = computed(() => this.form.controls.personTypeCode.value === 1);
  // Use DB-driven flags from reference-service when available; fall back to
  // hardcoded sets when the service is unavailable (signals empty).
  readonly requiresFatal = computed(() => {
    const code = this.form.controls.injuryStatusCode.value;
    if (code == null) return false;
    const live = this.refSvc.injuryStatuses();
    return live.length > 0
      ? this.refSvc.requiresFatalSection(code)
      : code === 1;
  });
  readonly isNonMotorist = computed(() => {
    const code = this.form.controls.personTypeCode.value;
    if (code == null) return false;
    const live = this.refSvc.personTypes();
    return live.length > 0
      ? this.refSvc.isNonMotoristType(code)
      : NM_PERSON_TYPES.has(code);
  });

  // ── Lookup entries ─────────────────────────────────────────────────────────
  // 2 entries covered by reference-service: live data preferred, static fallback.
  readonly PERSON_TYPE_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.personTypes();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(PERSON_TYPE_STATIC);
  });
  readonly INJURY_STATUS_ENTRIES = computed<[number, string][]>(() => {
    const live = this.refSvc.injuryStatuses();
    return live.length > 0 ? live.map(e => [e.code, e.description]) : entries(INJURY_STATUS_STATIC);
  });

  readonly SEX_CODE_ENTRIES              = entries(SEX_CODE);
  readonly INCIDENT_RESPONDER_ENTRIES    = entries(INCIDENT_RESPONDER);
  readonly SEATING_ROW_ENTRIES           = entries(SEATING_ROW);
  readonly SEATING_SEAT_ENTRIES          = entries(SEATING_SEAT);
  readonly RESTRAINT_ENTRIES             = entries(RESTRAINT);
  readonly YES_NO_ENTRIES                = entries(YES_NO);
  readonly EJECTION_ENTRIES              = entries(EJECTION);
  readonly AIRBAG_ENTRIES                = entries(AIRBAG);
  readonly DL_JURISDICTION_TYPE_ENTRIES  = entries(DL_JURISDICTION_TYPE);
  readonly DL_CLASS_ENTRIES              = entries(DL_CLASS);
  readonly DL_ENDORSEMENT_ENTRIES        = entries(DL_ENDORSEMENT);
  readonly DL_RESTRICTION_ENTRIES        = entries(DL_RESTRICTION);
  readonly DL_STATUS_TYPE_ENTRIES        = entries(DL_STATUS_TYPE);
  readonly DL_STATUS_ENTRIES             = entries(DL_STATUS);
  readonly SPEEDING_ENTRIES              = entries(SPEEDING);
  readonly DRIVER_ACTION_ENTRIES         = entries(DRIVER_ACTION);
  readonly DISTRACTED_ACTION_ENTRIES     = entries(DISTRACTED_ACTION);
  readonly DISTRACTED_SOURCE_ENTRIES     = entries(DISTRACTED_SOURCE);
  readonly DRIVER_CONDITION_ENTRIES      = entries(DRIVER_CONDITION);
  readonly ALCOHOL_TEST_STATUS_ENTRIES   = entries(ALCOHOL_TEST_STATUS);
  readonly ALCOHOL_TEST_TYPE_ENTRIES     = entries(ALCOHOL_TEST_TYPE);
  readonly DRUG_TEST_STATUS_ENTRIES      = entries(DRUG_TEST_STATUS);
  readonly DRUG_TEST_TYPE_ENTRIES        = entries(DRUG_TEST_TYPE);
  readonly DRUG_TEST_RESULT_ENTRIES      = entries(DRUG_TEST_RESULT);
  readonly TRANSPORT_SOURCE_ENTRIES      = entries(TRANSPORT_SOURCE);
  readonly INJURY_AREA_ENTRIES           = entries(INJURY_AREA);
  readonly INJURY_SEVERITY_ENTRIES       = entries(INJURY_SEVERITY);
  readonly MANEUVER_ENTRIES              = entries(MANEUVER);
  readonly NM_ACTION_CIRC_ENTRIES        = entries(NM_ACTION_CIRC);
  readonly NM_ORIGIN_DESTINATION_ENTRIES = entries(NM_ORIGIN_DESTINATION);
  readonly NM_CONTRIBUTING_ACTION_ENTRIES = entries(NM_CONTRIBUTING_ACTION);
  readonly NM_LOCATION_AT_CRASH_ENTRIES  = entries(NM_LOCATION_AT_CRASH);
  readonly NM_CONTACT_POINT_ENTRIES      = entries(NM_CONTACT_POINT);
  readonly NM_SAFETY_EQUIPMENT_ENTRIES   = entries(NM_SAFETY_EQUIPMENT);

  // ── Form ──────────────────────────────────────────────────────────────────
  readonly form = this.fb.nonNullable.group({
    // Identity (P1–P3)
    personName:            [null as string | null],
    dobYear:               [null as number | null],
    dobMonth:              [null as number | null],
    dobDay:                [null as number | null],
    ageYears:              [null as number | null],
    sexCode:               [null as number | null],
    // Person type & status (P4–P6)
    personTypeCode:        [null as number | null, Validators.required],
    incidentResponderCode: [null as number | null],
    injuryStatusCode:      [null as number | null, Validators.required],
    vehicleUnitNumber:     [null as number | null],
    // Seating & safety (P7–P10)
    seatingRowCode:        [null as number | null],
    seatingSeatCode:       [null as number | null],
    restraintCode:         [null as number | null],
    restraintImproperFlg:  [null as number | null],
    ejectionCode:          [null as number | null],
    // Driver license (P11–P17)
    dlJurisdictionType:    [null as number | null],
    dlJurisdictionCode:    ['' as string],
    dlNumber:              ['' as string],
    dlClassCode:           [null as number | null],
    dlIsCdlFlg:            [null as number | null],
    dlEndorsementCode:     [null as number | null],
    dlAlcoholInterlockFlg: [null as number | null],
    dlStatusTypeCode:      [null as number | null],
    dlStatusCode:          [null as number | null],
    // Behavior & conditions (P13–P19)
    speedingCode:          [null as number | null],
    violationCode1:        ['' as string],
    violationCode2:        ['' as string],
    distractedActionCode:  [null as number | null],
    distractedSourceCode:  [null as number | null],
    conditionCode1:        [null as number | null],
    conditionCode2:        [null as number | null],
    // Alcohol & drug (P20–P23)
    leSuspectsAlcohol:     [null as number | null],
    alcoholTestStatusCode: [null as number | null],
    alcoholTestTypeCode:   [null as number | null],
    alcoholBacResult:      ['' as string],
    leSuspectsDrug:        [null as number | null],
    drugTestStatusCode:    [null as number | null],
    drugTestTypeCode:      [null as number | null],
    // Medical (P24–P27)
    transportSourceCode:   [null as number | null],
    emsAgencyId:           ['' as string],
    emsRunNumber:          ['' as string],
    medicalFacility:       ['' as string],
    injuryAreaCode:        [null as number | null],
    injuryDiagnosis:       ['' as string],
    injurySeverityCode:    [null as number | null],
    // Fatal section (F1–F3)
    fatalAvoidanceManeuver: [null as number | null],
    fatalAlcoholTestType:   [null as number | null],
    fatalAlcoholTestResult: ['' as string],
    fatalDrugTestType:      [null as number | null],
    fatalDrugTestResult:    [null as number | null],
    // Non-motorist (NM1–NM6)
    nmStrikingVehicleUnit:  [null as number | null],
    nmActionCircCode:       [null as number | null],
    nmOriginDestination:    [null as number | null],
    nmContributingAction1:  [null as number | null],
    nmContributingAction2:  [null as number | null],
    nmLocationAtCrash:      [null as number | null],
    nmInitialContactPoint:  [null as number | null],
  });

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  ngOnInit(): void {
    const pid = this.personId();
    if (pid == null) return;

    this.loading.set(true);
    this.crashService.getPerson(this.crashId(), this.vehicleId(), pid)
      .pipe(
        catchError((err: unknown) => {
          this.errorMsg.set(err instanceof Error ? err.message : 'Failed to load person record.');
          this.loading.set(false);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(p => {
        this.form.patchValue({
          personName:            p.personName,
          dobYear:               p.dobYear,
          dobMonth:              p.dobMonth,
          dobDay:                p.dobDay,
          ageYears:              p.ageYears,
          sexCode:               p.sexCode,
          personTypeCode:        p.personTypeCode,
          incidentResponderCode: p.incidentResponderCode,
          injuryStatusCode:      p.injuryStatusCode,
          vehicleUnitNumber:     p.vehicleUnitNumber,
          seatingRowCode:        p.seatingRowCode,
          seatingSeatCode:       p.seatingSeatCode,
          restraintCode:         p.restraintCode,
          restraintImproperFlg:  p.restraintImproperFlg,
          ejectionCode:          p.ejectionCode,
          dlJurisdictionType:    p.dlJurisdictionType,
          dlJurisdictionCode:    p.dlJurisdictionCode ?? '',
          dlNumber:              p.dlNumber ?? '',
          dlClassCode:           p.dlClassCode,
          dlIsCdlFlg:            p.dlIsCdlFlg,
          dlEndorsementCode:     p.dlEndorsementCode,
          dlAlcoholInterlockFlg: p.dlAlcoholInterlockFlg,
          dlStatusTypeCode:      p.dlStatusTypeCode,
          dlStatusCode:          p.dlStatusCode,
          speedingCode:          p.speedingCode,
          violationCode1:        p.violationCode1 ?? '',
          violationCode2:        p.violationCode2 ?? '',
          distractedActionCode:  p.distractedActionCode,
          distractedSourceCode:  p.distractedSourceCode,
          conditionCode1:        p.conditionCode1,
          conditionCode2:        p.conditionCode2,
          leSuspectsAlcohol:     p.leSuspectsAlcohol,
          alcoholTestStatusCode: p.alcoholTestStatusCode,
          alcoholTestTypeCode:   p.alcoholTestTypeCode,
          alcoholBacResult:      p.alcoholBacResult ?? '',
          leSuspectsDrug:        p.leSuspectsDrug,
          drugTestStatusCode:    p.drugTestStatusCode,
          drugTestTypeCode:      p.drugTestTypeCode,
          transportSourceCode:   p.transportSourceCode,
          emsAgencyId:           p.emsAgencyId ?? '',
          emsRunNumber:          p.emsRunNumber ?? '',
          medicalFacility:       p.medicalFacility ?? '',
          injuryAreaCode:        p.injuryAreaCode,
          injuryDiagnosis:       p.injuryDiagnosis ?? '',
          injurySeverityCode:    p.injurySeverityCode,
          // Fatal section
          fatalAvoidanceManeuver: p.fatalSection?.avoidanceManeuverCode ?? null,
          fatalAlcoholTestType:   p.fatalSection?.alcoholTestTypeCode ?? null,
          fatalAlcoholTestResult: p.fatalSection?.alcoholTestResult ?? '',
          fatalDrugTestType:      p.fatalSection?.drugTestTypeCode ?? null,
          fatalDrugTestResult:    p.fatalSection?.drugTestResult ?? null,
          // Non-motorist
          nmStrikingVehicleUnit:  p.nonMotorist?.strikingVehicleUnit ?? null,
          nmActionCircCode:       p.nonMotorist?.actionCircCode ?? null,
          nmOriginDestination:    p.nonMotorist?.originDestinationCode ?? null,
          nmContributingAction1:  p.nonMotorist?.contributingAction1 ?? null,
          nmContributingAction2:  p.nonMotorist?.contributingAction2 ?? null,
          nmLocationAtCrash:      p.nonMotorist?.locationAtCrashCode ?? null,
          nmInitialContactPoint:  p.nonMotorist?.initialContactPoint ?? null,
        });

        this.selectedAirbags.set(new Set(p.airbags.map(a => a.code)));
        this.selectedDriverActions.set(new Set(p.driverActions.map(a => a.code)));
        this.selectedDlRestrictions.set(new Set(p.dlRestrictions.map(r => r.code)));
        this.selectedDrugResults.set(new Set(p.drugTestResults.map(r => r.resultCode)));
        this.selectedNmSafetyEquip.set(new Set((p.nonMotorist?.safetyEquipment ?? []).map(s => s.code)));

        this.loading.set(false);
      });
  }

  // ── Toggle helpers ─────────────────────────────────────────────────────────

  toggleAirbag(code: number): void {
    this.selectedAirbags.update(s => { const n = new Set(s); n.has(code) ? n.delete(code) : n.add(code); return n; });
  }

  toggleDriverAction(code: number): void {
    this.selectedDriverActions.update(s => { const n = new Set(s); n.has(code) ? n.delete(code) : n.add(code); return n; });
  }

  toggleDlRestriction(code: number): void {
    this.selectedDlRestrictions.update(s => { const n = new Set(s); n.has(code) ? n.delete(code) : n.add(code); return n; });
  }

  toggleDrugResult(code: number): void {
    this.selectedDrugResults.update(s => { const n = new Set(s); n.has(code) ? n.delete(code) : n.add(code); return n; });
  }

  toggleNmSafetyEquip(code: number): void {
    this.selectedNmSafetyEquip.update(s => { const n = new Set(s); n.has(code) ? n.delete(code) : n.add(code); return n; });
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  onSubmit(): void {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }
    this.saving.set(true);
    this.errorMsg.set('');

    const req  = this.buildRequest();
    const cid  = this.crashId();
    const vid  = this.vehicleId();
    const pid  = this.personId();

    const person$ = pid != null
      ? this.crashService.updatePerson(cid, vid, pid, req)
      : this.crashService.createPerson(cid, vid, req);

    person$.pipe(
      switchMap(saved => {
        const calls: Observable<unknown>[] = [];
        if (this.requiresFatal()) {
          calls.push(this.crashService.upsertFatalSection(cid, vid, saved.personId, this.buildFatalRequest()));
        }
        if (this.isNonMotorist()) {
          calls.push(this.crashService.upsertNonMotorist(cid, vid, saved.personId, this.buildNmRequest()));
        }
        return calls.length > 0 ? forkJoin(calls).pipe(map(() => saved)) : of(saved);
      }),
      catchError((err: unknown) => {
        this.errorMsg.set(err instanceof Error ? err.message : 'Failed to save person.');
        this.saving.set(false);
        return EMPTY;
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(() => {
      this.saving.set(false);
      this.router.navigate(['/crashes', cid], { fragment: 'persons' });
    });
  }

  onCancel(): void {
    this.router.navigate(['/crashes', this.crashId()], { fragment: 'persons' });
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  private buildRequest(): PersonRequest {
    const raw = this.form.getRawValue();

    const toNum = (v: number | null | string): number | null => {
      if (v === null || v === '') return null;
      const n = Number(v);
      return isNaN(n) ? null : n;
    };

    const toStr = (v: string): string | null =>
      v.trim() === '' ? null : v.trim();

    const setToSeq = (s: Set<number>): { sequenceNum: number; code: number }[] =>
      Array.from(s).sort((a, b) => a - b).map((code, i) => ({ sequenceNum: i + 1, code }));

    return {
      personName:            toStr(raw.personName ?? ''),
      dobYear:               toNum(raw.dobYear),
      dobMonth:              toNum(raw.dobMonth),
      dobDay:                toNum(raw.dobDay),
      ageYears:              toNum(raw.ageYears),
      sexCode:               toNum(raw.sexCode),
      personTypeCode:        toNum(raw.personTypeCode),
      incidentResponderCode: toNum(raw.incidentResponderCode),
      injuryStatusCode:      toNum(raw.injuryStatusCode),
      vehicleUnitNumber:     toNum(raw.vehicleUnitNumber),
      seatingRowCode:        toNum(raw.seatingRowCode),
      seatingSeatCode:       toNum(raw.seatingSeatCode),
      restraintCode:         toNum(raw.restraintCode),
      restraintImproperFlg:  toNum(raw.restraintImproperFlg),
      airbags:               setToSeq(this.selectedAirbags()),
      ejectionCode:          toNum(raw.ejectionCode),
      dlJurisdictionType:    toNum(raw.dlJurisdictionType),
      dlJurisdictionCode:    toStr(raw.dlJurisdictionCode),
      dlNumber:              toStr(raw.dlNumber),
      dlClassCode:           toNum(raw.dlClassCode),
      dlIsCdlFlg:            toNum(raw.dlIsCdlFlg),
      dlEndorsementCode:     toNum(raw.dlEndorsementCode),
      speedingCode:          toNum(raw.speedingCode),
      driverActions:         setToSeq(this.selectedDriverActions()),
      violationCode1:        toStr(raw.violationCode1),
      violationCode2:        toStr(raw.violationCode2),
      dlRestrictions:        setToSeq(this.selectedDlRestrictions()),
      dlAlcoholInterlockFlg: toNum(raw.dlAlcoholInterlockFlg),
      dlStatusTypeCode:      toNum(raw.dlStatusTypeCode),
      dlStatusCode:          toNum(raw.dlStatusCode),
      distractedActionCode:  toNum(raw.distractedActionCode),
      distractedSourceCode:  toNum(raw.distractedSourceCode),
      conditionCode1:        toNum(raw.conditionCode1),
      conditionCode2:        toNum(raw.conditionCode2),
      leSuspectsAlcohol:     toNum(raw.leSuspectsAlcohol),
      alcoholTestStatusCode: toNum(raw.alcoholTestStatusCode),
      alcoholTestTypeCode:   toNum(raw.alcoholTestTypeCode),
      alcoholBacResult:      toStr(raw.alcoholBacResult),
      leSuspectsDrug:        toNum(raw.leSuspectsDrug),
      drugTestStatusCode:    toNum(raw.drugTestStatusCode),
      drugTestTypeCode:      toNum(raw.drugTestTypeCode),
      drugTestResults:       Array.from(this.selectedDrugResults()).sort().map((code, i) => ({ sequenceNum: i + 1, resultCode: code })),
      transportSourceCode:   toNum(raw.transportSourceCode),
      emsAgencyId:           toStr(raw.emsAgencyId),
      emsRunNumber:          toStr(raw.emsRunNumber),
      medicalFacility:       toStr(raw.medicalFacility),
      injuryAreaCode:        toNum(raw.injuryAreaCode),
      injuryDiagnosis:       toStr(raw.injuryDiagnosis),
      injurySeverityCode:    toNum(raw.injurySeverityCode),
    };
  }

  private buildFatalRequest(): FatalSectionRequest {
    const raw = this.form.getRawValue();
    const toNum = (v: number | null): number | null => (v === null ? null : Number(v));
    const toStr = (v: string): string | null => (v.trim() === '' ? null : v.trim());
    return {
      avoidanceManeuverCode: toNum(raw.fatalAvoidanceManeuver),
      alcoholTestTypeCode:   toNum(raw.fatalAlcoholTestType),
      alcoholTestResult:     toStr(raw.fatalAlcoholTestResult),
      drugTestTypeCode:      toNum(raw.fatalDrugTestType),
      drugTestResult:        toNum(raw.fatalDrugTestResult),
    };
  }

  private buildNmRequest(): NonMotoristRequest {
    const raw = this.form.getRawValue();
    const toNum = (v: number | null): number | null => (v === null ? null : Number(v));
    return {
      strikingVehicleUnit:   toNum(raw.nmStrikingVehicleUnit),
      actionCircCode:        toNum(raw.nmActionCircCode),
      originDestinationCode: toNum(raw.nmOriginDestination),
      contributingAction1:   toNum(raw.nmContributingAction1),
      contributingAction2:   toNum(raw.nmContributingAction2),
      locationAtCrashCode:   toNum(raw.nmLocationAtCrash),
      initialContactPoint:   toNum(raw.nmInitialContactPoint),
      safetyEquipment:       Array.from(this.selectedNmSafetyEquip()).sort((a, b) => a - b).map((code, i) => ({ sequenceNum: i + 1, code })),
    };
  }
}
