import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { RouterLink } from '@angular/router';
import { forkJoin } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { of } from 'rxjs';
import { CrashService } from '../../core/services/crash.service';
import { CrashSummary } from '../../core/models/crash.models';
import { AlertComponent } from '../../shared/components/alert/alert.component';

interface StatCard {
  label: string;
  value: number | null;
  sub?: string;
  variant?: 'default' | 'danger' | 'warning';
}

@Component({
  selector: 'app-dashboard',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterLink, AlertComponent],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.scss',
})
export class DashboardComponent implements OnInit {
  private readonly crashService = inject(CrashService);
  private readonly destroyRef   = inject(DestroyRef);

  readonly loading      = signal(true);
  readonly errorMsg     = signal('');
  readonly recentCrashes = signal<CrashSummary[]>([]);

  readonly stats = signal<StatCard[]>([
    { label: 'Total Crashes',      value: null },
    { label: 'Fatal Crashes',      value: null, variant: 'danger' },
    { label: 'Crashes This Year',  value: null, variant: 'warning' },
    { label: 'Crashes This Month', value: null },
  ]);

  private readonly today      = new Date();
  private readonly yearStart  = `${this.today.getFullYear()}-01-01`;
  private readonly monthStart = `${this.today.getFullYear()}-${String(this.today.getMonth() + 1).padStart(2, '0')}-01`;

  readonly asOf = this.today.toLocaleDateString('en-US', {
    month: 'long', day: 'numeric', year: 'numeric',
  });

  ngOnInit(): void {
    const base = { dateTo: null, countyCode: null, sort: 'crashDate,desc' };

    forkJoin({
      recent:   this.crashService.getCrashes({ ...base, page: 0, size: 5, dateFrom: null, minFatalities: null }),
      fatal:    this.crashService.getCrashes({ ...base, page: 0, size: 1, dateFrom: null, minFatalities: 1 }),
      thisYear: this.crashService.getCrashes({ ...base, page: 0, size: 1, dateFrom: this.yearStart, minFatalities: null }),
      thisMonth:this.crashService.getCrashes({ ...base, page: 0, size: 1, dateFrom: this.monthStart, minFatalities: null }),
    }).pipe(
      catchError(() => {
        this.errorMsg.set('Failed to load dashboard data. Please try again.');
        this.loading.set(false);
        return of(null);
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(result => {
      if (!result) return;
      this.recentCrashes.set(result.recent.content);
      this.stats.set([
        { label: 'Total Crashes',      value: result.recent.totalElements },
        { label: 'Fatal Crashes',      value: result.fatal.totalElements,    variant: 'danger' },
        { label: 'Crashes This Year',  value: result.thisYear.totalElements, variant: 'warning' },
        { label: 'Crashes This Month', value: result.thisMonth.totalElements },
      ]);
      this.loading.set(false);
    });
  }

  // ── Formatting helpers ────────────────────────────────────────────────────

  formatDate(iso: string | null): string {
    if (!iso) return '—';
    const [year, month, day] = iso.split('-');
    return `${month}/${day}/${year}`;
  }

  severityLabel(code: number | null): string {
    const map: Record<number, string> = {
      1: 'Fatal', 2: 'Serious Injury', 3: 'Minor Injury',
      4: 'Possible Injury', 5: 'PDO',
    };
    return code != null ? (map[code] ?? `Code ${code}`) : '—';
  }

  severityClass(code: number | null): string {
    const map: Record<number, string> = {
      1: 'badge--danger', 2: 'badge--warning', 3: 'badge--warning',
      4: 'badge--info', 5: 'badge--neutral',
    };
    return code != null ? (map[code] ?? 'badge--neutral') : 'badge--neutral';
  }

  formatLocation(c: CrashSummary): string {
    const parts = [c.cityPlaceName, c.countyName].filter(Boolean);
    return parts.join(', ') || '—';
  }
}
