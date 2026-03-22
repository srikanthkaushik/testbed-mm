import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed, toSignal } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterLink } from '@angular/router';
import { debounceTime, distinctUntilChanged, switchMap, tap, catchError } from 'rxjs/operators';
import { EMPTY, Subject } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { AuthService } from '../../../core/services/auth.service';
import { CrashFilter, CrashSummary, Page } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';

/** Default number of results per page. */
const DEFAULT_PAGE_SIZE = 20;
/** Default sort order. */
const DEFAULT_SORT = 'crashDate,desc';

@Component({
  selector: 'app-crash-list',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, RouterLink, AlertComponent],
  templateUrl: './crash-list.component.html',
  styleUrl: './crash-list.component.scss',
})
export class CrashListComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly authService  = inject(AuthService);
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly fb = inject(FormBuilder);
  private readonly destroyRef = inject(DestroyRef);

  // ── Role-based access ─────────────────────────────────────────────────
  private readonly authState = toSignal(this.authService.state$);
  readonly canDelete = computed(() => this.authState()?.user?.roleCode === 'ADMIN');

  // ── Local UI state (signals) ──────────────────────────────────────────
  readonly loading         = signal<boolean>(false);
  readonly errorMessage    = signal<string>('');
  readonly page            = signal<Page<CrashSummary> | null>(null);
  readonly deletingCrashId = signal<number | null>(null);
  readonly deleteError     = signal<string>('');

  /** Current sort direction for crashDate column. */
  readonly sortAsc = signal<boolean>(false);

  /** Current page number (0-based). */
  readonly currentPage = signal<number>(0);

  /** Current page size. */
  readonly pageSize = signal<number>(DEFAULT_PAGE_SIZE);

  // ── Computed helpers ──────────────────────────────────────────────────

  /** 1-based start record number for the "Showing X–Y of Z" label. */
  readonly rangeStart = computed<number>(() => {
    const p = this.page();
    if (!p || p.totalElements === 0) return 0;
    return p.number * p.size + 1;
  });

  /** 1-based end record number. */
  readonly rangeEnd = computed<number>(() => {
    const p = this.page();
    if (!p) return 0;
    return Math.min(p.number * p.size + p.size, p.totalElements);
  });

  /** Skeleton row indices for shimmer placeholders. */
  readonly skeletonRows = [0, 1, 2, 3, 4];

  /** Available page size options. */
  readonly pageSizeOptions = [10, 20, 50];

  // ── Filter form ───────────────────────────────────────────────────────
  readonly filterForm = this.fb.nonNullable.group({
    dateFrom: [''],
    dateTo:   [''],
    county:   [''],    // county name — client-side hint only (UI display)
    severity: [''],    // crash severity code 1–5
  });

  /** Severity options for the filter dropdown. */
  readonly severityOptions: { code: number; label: string }[] = [
    { code: 1, label: 'Fatal (K)' },
    { code: 2, label: 'Serious Injury (A)' },
    { code: 3, label: 'Minor Injury (B)' },
    { code: 4, label: 'Possible Injury (C)' },
    { code: 5, label: 'PDO / No Injury (O)' },
  ];

  // ── Fetch trigger ─────────────────────────────────────────────────────
  private readonly fetch$ = new Subject<void>();

  // ── Lifecycle ─────────────────────────────────────────────────────────

  ngOnInit(): void {
    // Restore filter state from URL query params (supports back-button / bookmarks)
    const qp = this.route.snapshot.queryParams;
    if (qp['dateFrom']) this.filterForm.controls.dateFrom.setValue(qp['dateFrom']);
    if (qp['dateTo'])   this.filterForm.controls.dateTo.setValue(qp['dateTo']);
    if (qp['county'])   this.filterForm.controls.county.setValue(qp['county']);
    if (qp['severity']) this.filterForm.controls.severity.setValue(qp['severity']);
    if (qp['page'])  this.currentPage.set(parseInt(qp['page'], 10) || 0);
    if (qp['size'])  this.pageSize.set(parseInt(qp['size'], 10) || DEFAULT_PAGE_SIZE);
    if (qp['sort'] === 'crashDate,asc') this.sortAsc.set(true);

    // Wire the fetch subject to the service call
    this.fetch$
      .pipe(
        tap(() => {
          this.loading.set(true);
          this.errorMessage.set('');
        }),
        switchMap(() =>
          this.crashService.getCrashes(this.buildFilter()).pipe(
            catchError((err: unknown) => {
              const msg =
                err instanceof Error
                  ? err.message
                  : 'Failed to load crashes. Please try again.';
              this.errorMessage.set(msg);
              this.loading.set(false);
              return EMPTY;
            }),
          ),
        ),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe((result) => {
        this.page.set(result);
        this.loading.set(false);
      });

    // Initial fetch
    this.fetch$.next();
  }

  // ── User actions ──────────────────────────────────────────────────────

  applyFilters(): void {
    this.currentPage.set(0);
    this.syncUrl();
    this.fetch$.next();
  }

  clearFilters(): void {
    this.filterForm.reset();
    this.currentPage.set(0);
    this.syncUrl();
    this.fetch$.next();
  }

  goToPage(pageIndex: number): void {
    this.currentPage.set(pageIndex);
    this.syncUrl();
    this.fetch$.next();
  }

  changePageSize(event: Event): void {
    const size = parseInt((event.target as HTMLSelectElement).value, 10);
    this.pageSize.set(size);
    this.currentPage.set(0);
    this.syncUrl();
    this.fetch$.next();
  }

  toggleSort(): void {
    this.sortAsc.update((v) => !v);
    this.currentPage.set(0);
    this.syncUrl();
    this.fetch$.next();
  }

  // ── Delete helpers ────────────────────────────────────────────────────

  startDelete(id: number, event: Event): void {
    event.stopPropagation();
    this.deleteError.set('');
    this.deletingCrashId.set(id);
  }

  cancelDelete(event: Event): void {
    event.stopPropagation();
    this.deletingCrashId.set(null);
    this.deleteError.set('');
  }

  confirmDelete(id: number, event: Event): void {
    event.stopPropagation();
    this.deleteError.set('');
    this.crashService.deleteCrash(id)
      .pipe(
        catchError((err: unknown) => {
          this.deleteError.set(err instanceof Error ? err.message : 'Failed to delete crash.');
          this.deletingCrashId.set(null);
          return EMPTY;
        }),
        takeUntilDestroyed(this.destroyRef),
      )
      .subscribe(() => {
        this.deletingCrashId.set(null);
        this.fetch$.next();
      });
  }

  // ── Formatting helpers ────────────────────────────────────────────────

  /**
   * Formats an ISO date string ("YYYY-MM-DD") to "MM/DD/YYYY".
   * Returns empty string for falsy input.
   */
  formatDate(isoDate: string | null): string {
    if (!isoDate) return '';
    const [year, month, day] = isoDate.split('-');
    return `${month}/${day}/${year}`;
  }

  /**
   * Builds a human-readable location string from city and county.
   */
  formatLocation(crash: CrashSummary): string {
    const parts = [crash.cityPlaceName, crash.countyName].filter(Boolean);
    return parts.join(', ') || '—';
  }

  /**
   * Returns a human-readable severity label for a MMUCC crash severity code.
   * Codes: 1=Fatal, 2=Serious Injury, 3=Minor Injury, 4=Possible Injury, 5=No Apparent Injury (PDO)
   */
  severityLabel(code: number | null): string {
    const labels: Record<number, string> = {
      1: 'Fatal',
      2: 'Serious Injury',
      3: 'Minor Injury',
      4: 'Possible Injury',
      5: 'PDO',
    };
    return code != null ? (labels[code] ?? `Code ${code}`) : '—';
  }

  // ── Private helpers ───────────────────────────────────────────────────

  private buildFilter(): CrashFilter {
    const raw = this.filterForm.getRawValue();
    const severityNum = raw.severity ? parseInt(raw.severity, 10) : null;
    return {
      dateFrom:     raw.dateFrom || null,
      dateTo:       raw.dateTo || null,
      countyCode:   null,   // county name filter is client-side only; FIPS not collected in this field
      severityCode: severityNum !== null && !isNaN(severityNum) ? severityNum : null,
      minFatalities: null,
      page: this.currentPage(),
      size: this.pageSize(),
      sort: this.sortAsc() ? 'crashDate,asc' : DEFAULT_SORT,
    };
  }

  private syncUrl(): void {
    const raw = this.filterForm.getRawValue();
    const queryParams: Record<string, string | number> = {
      page: this.currentPage(),
      size: this.pageSize(),
      sort: this.sortAsc() ? 'crashDate,asc' : DEFAULT_SORT,
    };
    if (raw.dateFrom) queryParams['dateFrom'] = raw.dateFrom;
    if (raw.dateTo)   queryParams['dateTo']   = raw.dateTo;
    if (raw.county)   queryParams['county']   = raw.county;
    if (raw.severity) queryParams['severity'] = raw.severity;

    this.router.navigate([], {
      relativeTo: this.route,
      queryParams,
      replaceUrl: true,
    });
  }
}
