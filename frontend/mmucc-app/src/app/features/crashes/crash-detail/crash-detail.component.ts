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
import { ActivatedRoute, RouterLink } from '@angular/router';
import { switchMap, tap, catchError } from 'rxjs/operators';
import { EMPTY, of } from 'rxjs';
import { CrashService } from '../../../core/services/crash.service';
import { CrashDetail, VehicleDetail } from '../../../core/models/crash.models';
import { AlertComponent } from '../../../shared/components/alert/alert.component';

export type DetailTab = 'overview' | 'vehicles' | 'roadway' | 'audit';

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
  private readonly route = inject(ActivatedRoute);
  private readonly destroyRef = inject(DestroyRef);

  readonly loading = signal<boolean>(true);
  readonly errorMessage = signal<string>('');
  readonly crash = signal<CrashDetail | null>(null);
  readonly activeTab = signal<DetailTab>('overview');

  readonly tabs: { id: DetailTab; label: string }[] = [
    { id: 'overview', label: 'Overview' },
    { id: 'vehicles', label: 'Vehicles' },
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
}
