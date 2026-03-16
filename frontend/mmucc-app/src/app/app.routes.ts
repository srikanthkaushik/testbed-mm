import { Component, ChangeDetectionStrategy } from '@angular/core';
import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

/**
 * Inline stub component used as a placeholder for routes that are not yet
 * implemented. Defined here to avoid creating separate files for stubs.
 */
@Component({
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div class="coming-soon">
      <h2>Coming Soon</h2>
      <p>This section is under construction.</p>
    </div>
  `,
  styles: [
    `.coming-soon { padding: var(--space-8); color: var(--color-text-muted); }`,
  ],
})
class ComingSoonComponent {}

export const routes: Routes = [
  // ── Authenticated shell ──────────────────────────────────────────────────
  {
    path: '',
    loadComponent: () =>
      import('./features/shell/shell.component').then((m) => m.ShellComponent),
    canActivate: [authGuard],
    children: [
      // Default redirect to crash list
      { path: '', redirectTo: 'crashes', pathMatch: 'full' },

      // Dashboard (placeholder)
      {
        path: 'dashboard',
        component: ComingSoonComponent,
        title: 'Dashboard — MMUCC Crash Reporting',
      },

      // Crash list
      {
        path: 'crashes',
        loadComponent: () =>
          import(
            './features/crashes/crash-list/crash-list.component'
          ).then((m) => m.CrashListComponent),
        title: 'Crashes — MMUCC Crash Reporting',
      },

      // Crash detail
      {
        path: 'crashes/:id',
        loadComponent: () =>
          import(
            './features/crashes/crash-detail/crash-detail.component'
          ).then((m) => m.CrashDetailComponent),
        title: 'Crash Detail — MMUCC Crash Reporting',
      },

      // Reports (placeholder)
      {
        path: 'reports',
        component: ComingSoonComponent,
        title: 'Reports — MMUCC Crash Reporting',
      },

      // Admin users (placeholder)
      {
        path: 'admin/users',
        component: ComingSoonComponent,
        title: 'Admin: Users — MMUCC Crash Reporting',
      },
    ],
  },

  // ── Public routes ────────────────────────────────────────────────────────
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login/login.component').then(
        (m) => m.LoginComponent,
      ),
    title: 'Sign In — MMUCC Crash Reporting',
  },

  // ── Fallback ─────────────────────────────────────────────────────────────
  {
    path: '**',
    redirectTo: '',
  },
];
