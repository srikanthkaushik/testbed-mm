import { Injectable, OnDestroy, inject } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { Router } from '@angular/router';
import { BehaviorSubject, Observable, firstValueFrom, Subscription } from 'rxjs';
import { FirebaseAuthService } from './firebase-auth.service';
import { AuthState, LoginRequest, TokenResponse, UserSummary } from '../models/auth.models';
import { environment } from '../../../environments/environment';

/**
 * Manages the application auth session.
 *
 * Token strategy:
 *  - Access token held in memory only (never localStorage / sessionStorage).
 *  - Refresh token travels as an HttpOnly SameSite=Strict cookie; the browser
 *    sends it automatically to POST /auth/refresh — the app never reads it.
 *  - A timer fires 60 s before access-token expiry to silently refresh.
 */
@Injectable({ providedIn: 'root' })
export class AuthService implements OnDestroy {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly firebase = inject(FirebaseAuthService);

  private readonly baseUrl = environment.authServiceUrl;

  /** Emits the current auth state; null = unauthenticated. */
  private readonly _state$ = new BehaviorSubject<AuthState | null>(null);
  readonly state$: Observable<AuthState | null> = this._state$.asObservable();

  /** Convenience: emits only the user object. */
  get currentUser(): UserSummary | null {
    return this._state$.value?.user ?? null;
  }

  get isAuthenticated(): boolean {
    const state = this._state$.value;
    return state !== null && Date.now() < state.expiresAt;
  }

  get accessToken(): string | null {
    return this._state$.value?.accessToken ?? null;
  }

  private refreshTimer: ReturnType<typeof setTimeout> | null = null;
  private refreshSub: Subscription | null = null;

  // ── Public API ────────────────────────────────────────────────

  /** Sign in via Google popup → Firebase ID token → backend JWT. */
  async loginWithGoogle(): Promise<void> {
    const firebaseIdToken = await this.firebase.signInWithGoogle();
    await this.exchangeFirebaseToken(firebaseIdToken);
  }

  /** Sign in with email + password → Firebase ID token → backend JWT. */
  async loginWithEmail(email: string, password: string): Promise<void> {
    const firebaseIdToken = await this.firebase.signInWithEmailAndPassword(
      email,
      password,
    );
    await this.exchangeFirebaseToken(firebaseIdToken);
  }

  /** Exchange a Firebase ID token for a backend JWT. */
  private async exchangeFirebaseToken(firebaseIdToken: string): Promise<void> {
    const body: LoginRequest = { firebaseIdToken };
    const response = await firstValueFrom(
      this.http.post<TokenResponse>(`${this.baseUrl}/login`, body, {
        withCredentials: true,  // allow the HttpOnly refresh cookie to be set
      }),
    );
    this.applyTokenResponse(response);
  }

  /**
   * Silently refresh the access token using the HttpOnly refresh cookie.
   * Called automatically by the refresh timer and by the auth interceptor on 401.
   */
  async refresh(): Promise<string> {
    const response = await firstValueFrom(
      this.http.post<TokenResponse>(`${this.baseUrl}/refresh`, null, {
        withCredentials: true,
      }),
    );
    this.applyTokenResponse(response);
    return response.accessToken;
  }

  /** POST /auth/logout → clear state → Firebase sign-out → redirect to /login. */
  async logout(): Promise<void> {
    this.clearRefreshTimer();
    try {
      await firstValueFrom(
        this.http.post<void>(`${this.baseUrl}/logout`, null, {
          withCredentials: true,
        }),
      );
    } catch {
      // Best-effort: always clear local state even if the request fails
    }
    await this.firebase.signOut().catch(() => undefined);
    this._state$.next(null);
    await this.router.navigate(['/login']);
  }

  // ── Initialisation (called by APP_INITIALIZER) ──────────────

  /**
   * On startup, attempt a silent token refresh using the existing
   * HttpOnly refresh cookie. Fails silently if no cookie is present.
   */
  async tryRestoreSession(): Promise<void> {
    try {
      await this.refresh();
    } catch {
      // No valid refresh cookie — user must log in
    }
  }

  // ── Internal helpers ─────────────────────────────────────────

  private applyTokenResponse(response: TokenResponse): void {
    const expiresAt = Date.now() + response.expiresIn * 1000;
    this._state$.next({
      accessToken: response.accessToken,
      expiresAt,
      user: response.user,
    });
    this.scheduleRefresh(response.expiresIn);
  }

  private scheduleRefresh(expiresInSeconds: number): void {
    this.clearRefreshTimer();
    // Refresh 60 s before expiry (but not if token is already nearly expired)
    const delayMs = Math.max((expiresInSeconds - 60) * 1000, 0);
    this.refreshTimer = setTimeout(async () => {
      try {
        await this.refresh();
      } catch {
        // Refresh failed — clear state and redirect
        this._state$.next(null);
        await this.router.navigate(['/login']);
      }
    }, delayMs);
  }

  private clearRefreshTimer(): void {
    if (this.refreshTimer !== null) {
      clearTimeout(this.refreshTimer);
      this.refreshTimer = null;
    }
  }

  ngOnDestroy(): void {
    this.clearRefreshTimer();
    this.refreshSub?.unsubscribe();
  }
}
