import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

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

      // Dashboard
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./features/dashboard/dashboard.component').then(m => m.DashboardComponent),
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

      // Vehicle form — must be before crashes/:id so the nested segments are matched first
      {
        path: 'crashes/:crashId/vehicles/new',
        loadComponent: () =>
          import(
            './features/crashes/vehicle-form/vehicle-form.component'
          ).then((m) => m.VehicleFormComponent),
        title: 'Add Vehicle — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },
      {
        path: 'crashes/:crashId/vehicles/:vehicleId/edit',
        loadComponent: () =>
          import(
            './features/crashes/vehicle-form/vehicle-form.component'
          ).then((m) => m.VehicleFormComponent),
        title: 'Edit Vehicle — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Roadway form — must be before crashes/:id to prevent param conflicts
      {
        path: 'crashes/:crashId/roadway/edit',
        loadComponent: () =>
          import('./features/crashes/roadway-form/roadway-form.component')
            .then(m => m.RoadwayFormComponent),
        title: 'Edit Roadway — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Automation form — must be before crashes/:id to prevent param conflicts
      {
        path: 'crashes/:crashId/vehicles/:vehicleId/automation',
        loadComponent: () =>
          import('./features/crashes/vehicle-automation-form/vehicle-automation-form.component')
            .then(m => m.VehicleAutomationFormComponent),
        title: 'Edit Automation — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Large Vehicle form — must be before crashes/:id to prevent param conflicts
      {
        path: 'crashes/:crashId/vehicles/:vehicleId/large-vehicle',
        loadComponent: () =>
          import('./features/crashes/large-vehicle-form/large-vehicle-form.component')
            .then(m => m.LargeVehicleFormComponent),
        title: 'Edit Large Vehicle — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Person form — must be before crashes/:id to prevent param conflicts
      {
        path: 'crashes/:crashId/vehicles/:vehicleId/persons/new',
        loadComponent: () =>
          import('./features/crashes/person-form/person-form.component')
            .then(m => m.PersonFormComponent),
        title: 'Add Person — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },
      {
        path: 'crashes/:crashId/vehicles/:vehicleId/persons/:personId/edit',
        loadComponent: () =>
          import('./features/crashes/person-form/person-form.component')
            .then(m => m.PersonFormComponent),
        title: 'Edit Person — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Crash create — must be before crashes/:id to avoid "new" matching as an id
      {
        path: 'crashes/new',
        loadComponent: () =>
          import(
            './features/crashes/crash-form/crash-form.component'
          ).then((m) => m.CrashFormComponent),
        title: 'New Crash — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Crash edit
      {
        path: 'crashes/:id/edit',
        loadComponent: () =>
          import(
            './features/crashes/crash-form/crash-form.component'
          ).then((m) => m.CrashFormComponent),
        title: 'Edit Crash — MMUCC Crash Reporting',
        canActivate: [authGuard],
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

      // Reports
      {
        path: 'reports',
        loadComponent: () =>
          import('./features/reports/reports.component').then(m => m.ReportsComponent),
        title: 'Reports — MMUCC Crash Reporting',
        canActivate: [authGuard],
      },

      // Admin users
      {
        path: 'admin/users',
        loadComponent: () =>
          import('./features/admin/admin-users.component').then(m => m.AdminUsersComponent),
        title: 'Admin: Users — MMUCC Crash Reporting',
        canActivate: [authGuard],
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
