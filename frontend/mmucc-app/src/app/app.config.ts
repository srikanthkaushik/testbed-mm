import { ApplicationConfig, APP_INITIALIZER } from '@angular/core';
import {
  provideRouter,
  withComponentInputBinding,
  withEnabledBlockingInitialNavigation,
} from '@angular/router';
import {
  provideHttpClient,
  withInterceptors,
  withFetch,
} from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { routes } from './app.routes';
import { authInterceptor } from './core/interceptors/auth.interceptor';
import { AuthService } from './core/services/auth.service';
import { ReferenceService } from './core/services/reference.service';

/**
 * Attempt to restore a previous session from the HttpOnly refresh cookie
 * before the first navigation. This prevents a flash-of-login-page for
 * returning users who still have a valid refresh token.
 */
function initSession(authService: AuthService): () => Promise<void> {
  return () => authService.tryRestoreSession();
}

/**
 * Pre-load all MMUCC coded-value reference data from reference-service.
 * Runs in parallel with session restore. Failure is non-fatal.
 */
function initLookups(referenceService: ReferenceService): () => Promise<void> {
  return () => referenceService.loadAll();
}

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter(
      routes,
      withComponentInputBinding(),
      withEnabledBlockingInitialNavigation(),
    ),
    provideHttpClient(
      withFetch(),
      withInterceptors([authInterceptor]),
    ),
    provideAnimations(),
    {
      provide: APP_INITIALIZER,
      useFactory: initSession,
      deps: [AuthService],
      multi: true,
    },
    {
      provide: APP_INITIALIZER,
      useFactory: initLookups,
      deps: [ReferenceService],
      multi: true,
    },
  ],
};
