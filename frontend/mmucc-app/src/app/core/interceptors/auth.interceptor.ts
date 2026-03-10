import {
  HttpInterceptorFn,
  HttpRequest,
  HttpHandlerFn,
  HttpErrorResponse,
} from '@angular/common/http';
import { inject } from '@angular/core';
import { catchError, from, switchMap, throwError } from 'rxjs';
import { AuthService } from '../services/auth.service';

/**
 * Attaches the in-memory access token to every outbound API request and
 * handles a single silent 401 → refresh → retry cycle.
 *
 * Requests to /auth/refresh and /auth/login are excluded to avoid loops.
 */
export const authInterceptor: HttpInterceptorFn = (
  req: HttpRequest<unknown>,
  next: HttpHandlerFn,
) => {
  const authService = inject(AuthService);

  // Do not intercept login/refresh endpoints
  if (isAuthEndpoint(req.url)) {
    return next(req);
  }

  const token = authService.accessToken;
  const authorisedReq = token ? addBearerToken(req, token) : req;

  return next(authorisedReq).pipe(
    catchError((error: unknown) => {
      if (error instanceof HttpErrorResponse && error.status === 401) {
        // Attempt silent token refresh then retry once
        return from(authService.refresh()).pipe(
          switchMap((newToken) => next(addBearerToken(req, newToken))),
          catchError((refreshError) => throwError(() => refreshError)),
        );
      }
      return throwError(() => error);
    }),
  );
};

function addBearerToken(
  req: HttpRequest<unknown>,
  token: string,
): HttpRequest<unknown> {
  return req.clone({
    setHeaders: { Authorization: `Bearer ${token}` },
  });
}

function isAuthEndpoint(url: string): boolean {
  return url.includes('/auth/login') || url.includes('/auth/refresh');
}
