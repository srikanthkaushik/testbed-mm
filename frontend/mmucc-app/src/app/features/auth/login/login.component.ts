import {
  ChangeDetectionStrategy,
  ChangeDetectorRef,
  Component,
  inject,
  OnInit,
  signal,
} from '@angular/core';
import {
  AbstractControl,
  FormBuilder,
  ReactiveFormsModule,
  ValidationErrors,
  Validators,
} from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { AlertComponent } from '../../../shared/components/alert/alert.component';

/**
 * Login page component.
 *
 * ADA compliance:
 *  - Single <h1> page title
 *  - All inputs have explicit <label for="...">
 *  - aria-invalid / aria-describedby on invalid fields
 *  - Loading state communicated via aria-busy + sr-only text
 *  - Errors announced via role="alert" (assertive)
 *  - Password visibility toggle with distinct aria-label states
 *  - Skip link handled in AppComponent / global styles
 *  - Minimum 4.5:1 contrast on all text (see login.component.scss)
 *  - Focus rings never suppressed
 */
@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule, AlertComponent],
  changeDetection: ChangeDetectionStrategy.OnPush,
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss'],
})
export class LoginComponent implements OnInit {
  private readonly fb = inject(FormBuilder);
  private readonly authService = inject(AuthService);
  private readonly router = inject(Router);
  private readonly route = inject(ActivatedRoute);
  private readonly cdr = inject(ChangeDetectorRef);

  // ── Form ──────────────────────────────────────────────────────
  readonly form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  // ── UI state ──────────────────────────────────────────────────
  loading = signal(false);
  googleLoading = signal(false);
  showPassword = signal(false);
  errorMessage = signal('');

  private returnUrl = '/dashboard';

  // ── Lifecycle ─────────────────────────────────────────────────
  ngOnInit(): void {
    // If user is already authenticated, redirect immediately
    if (this.authService.isAuthenticated) {
      this.router.navigate([this.returnUrl]);
      return;
    }
    this.returnUrl =
      this.route.snapshot.queryParamMap.get('returnUrl') ?? '/dashboard';
  }

  // ── Actions ───────────────────────────────────────────────────

  async signInWithGoogle(): Promise<void> {
    this.clearError();
    this.googleLoading.set(true);
    this.cdr.markForCheck();

    try {
      await this.authService.loginWithGoogle();
      await this.router.navigate([this.returnUrl]);
    } catch (err) {
      this.setError(this.mapError(err));
    } finally {
      this.googleLoading.set(false);
      this.cdr.markForCheck();
    }
  }

  async signInWithEmail(): Promise<void> {
    this.form.markAllAsTouched();
    if (this.form.invalid) return;

    this.clearError();
    this.loading.set(true);
    this.cdr.markForCheck();

    try {
      const { email, password } = this.form.getRawValue();
      await this.authService.loginWithEmail(email!, password!);
      await this.router.navigate([this.returnUrl]);
    } catch (err) {
      this.setError(this.mapError(err));
    } finally {
      this.loading.set(false);
      this.cdr.markForCheck();
    }
  }

  togglePasswordVisibility(): void {
    this.showPassword.update((v) => !v);
  }

  // ── Field helpers (used in template) ─────────────────────────

  isInvalid(controlName: string): boolean {
    const ctrl = this.form.get(controlName);
    return !!(ctrl && ctrl.invalid && ctrl.touched);
  }

  getError(controlName: string): string {
    const ctrl = this.form.get(controlName);
    if (!ctrl || !ctrl.errors || !ctrl.touched) return '';
    return this.describeErrors(controlName, ctrl.errors);
  }

  // ── Internal helpers ─────────────────────────────────────────

  private clearError(): void {
    this.errorMessage.set('');
  }

  private setError(msg: string): void {
    this.errorMessage.set(msg);
  }

  private mapError(err: unknown): string {
    if (err instanceof Error) {
      // Firebase error codes
      const code = (err as { code?: string }).code ?? '';
      if (code === 'auth/popup-closed-by-user')   return '';
      if (code === 'auth/user-not-found')          return 'No account found with this email address.';
      if (code === 'auth/wrong-password')          return 'Incorrect password. Please try again.';
      if (code === 'auth/too-many-requests')       return 'Too many failed attempts. Please wait a few minutes and try again.';
      if (code === 'auth/network-request-failed')  return 'Network error. Please check your connection and try again.';
      if (code === 'auth/popup-blocked')           return 'Pop-up was blocked by your browser. Please allow pop-ups for this site or use email sign-in.';
      if (code.startsWith('auth/'))                return 'Authentication failed. Please try again.';

      // Backend HTTP errors
      const status = (err as { status?: number }).status;
      if (status === 401) return 'Your credentials could not be verified. Please try again.';
      if (status === 403) return 'Your account has been disabled or locked. Please contact your administrator.';
      if (status === 0)   return 'Unable to reach the server. Please check your connection.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  private describeErrors(
    field: string,
    errors: ValidationErrors,
  ): string {
    if (errors['required'])  return `${this.fieldLabel(field)} is required.`;
    if (errors['email'])     return 'Please enter a valid email address (e.g. name@agency.gov).';
    if (errors['minlength']) {
      const req = errors['minlength'].requiredLength as number;
      return `Password must be at least ${req} characters.`;
    }
    return 'Invalid value.';
  }

  private fieldLabel(name: string): string {
    return name === 'email' ? 'Email address' : 'Password';
  }
}
