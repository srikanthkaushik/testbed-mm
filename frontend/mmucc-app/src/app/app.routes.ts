import { Routes } from '@angular/router';
import { authGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'dashboard',
  },
  {
    path: 'login',
    loadComponent: () =>
      import('./features/auth/login/login.component').then(
        (m) => m.LoginComponent,
      ),
    title: 'Sign In — MMUCC Crash Reporting',
  },
  {
    path: 'dashboard',
    canActivate: [authGuard],
    // Placeholder until Sprint 2 dashboard is built
    loadComponent: () =>
      import('./features/auth/login/login.component').then(
        (m) => m.LoginComponent,
      ),
    title: 'Dashboard — MMUCC Crash Reporting',
  },
  {
    path: '**',
    redirectTo: 'login',
  },
];
