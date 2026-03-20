import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap, map, catchError, of } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AllLookups, LookupEntry } from '../models/reference.models';

/**
 * Fetches all MMUCC coded-value reference data from the reference-service
 * once at app startup and exposes them as read-only signals.
 *
 * Usage: inject ReferenceService in any component to access pre-loaded options.
 * The APP_INITIALIZER in app.config.ts calls loadAll() before first navigation.
 */
@Injectable({ providedIn: 'root' })
export class ReferenceService {
  private readonly http    = inject(HttpClient);
  private readonly baseUrl = environment.referenceServiceUrl;

  // ── Lookup signals ──────────────────────────────────────────────────────
  readonly crashTypes        = signal<LookupEntry[]>([]);
  readonly harmfulEvents     = signal<LookupEntry[]>([]);
  readonly weatherConditions = signal<LookupEntry[]>([]);
  readonly surfaceConditions = signal<LookupEntry[]>([]);
  readonly personTypes       = signal<LookupEntry[]>([]);
  readonly injuryStatuses    = signal<LookupEntry[]>([]);
  readonly bodyTypes         = signal<LookupEntry[]>([]);

  private loaded = false;

  /**
   * Fetches all lookup types in a single request.
   * Safe to call multiple times — subsequent calls are no-ops.
   * On error the signals remain empty and the app continues without reference data.
   */
  loadAll(): Promise<void> {
    if (this.loaded) return Promise.resolve();

    return this.http.get<AllLookups>(this.baseUrl).pipe(
      tap(data => {
        this.crashTypes.set(data['crash-types']        ?? []);
        this.harmfulEvents.set(data['harmful-events']  ?? []);
        this.weatherConditions.set(data['weather-conditions'] ?? []);
        this.surfaceConditions.set(data['surface-conditions'] ?? []);
        this.personTypes.set(data['person-types']      ?? []);
        this.injuryStatuses.set(data['injury-statuses'] ?? []);
        this.bodyTypes.set(data['body-types']          ?? []);
        this.loaded = true;
      }),
      map(() => undefined as void),
      catchError(() => {
        // Reference-service unavailable — app still works with static fallback maps
        console.warn('reference-service unavailable; lookup dropdowns will use static fallback data');
        return of(undefined as void);
      }),
    ).toPromise() as Promise<void>;
  }

  // ── Convenience helpers ─────────────────────────────────────────────────

  /** Returns the description for a given code in a lookup list, or the code itself as a fallback. */
  label(entries: LookupEntry[], code: number | null): string {
    if (code == null) return '—';
    return entries.find(e => e.code === code)?.description ?? String(code);
  }

  /** True when the given personTypeCode triggers the Non-Motorist section. */
  isNonMotoristType(code: number | null): boolean {
    if (code == null) return false;
    const entry = this.personTypes().find(e => e.code === code);
    return entry?.isNonMotorist ?? false;
  }

  /** True when the given injuryStatusCode requires the Fatal Section. */
  requiresFatalSection(code: number | null): boolean {
    if (code == null) return false;
    const entry = this.injuryStatuses().find(e => e.code === code);
    return entry?.requiresFatalSection ?? false;
  }

  /** True when the given bodyTypeCode requires the Large Vehicle section. */
  requiresLvSection(code: number | null): boolean {
    if (code == null) return false;
    const entry = this.bodyTypes().find(e => e.code === code);
    return entry?.requiresLvSection ?? false;
  }
}
