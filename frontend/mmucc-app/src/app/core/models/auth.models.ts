/** Mirrors auth-service LoginRequest DTO */
export interface LoginRequest {
  firebaseIdToken: string;
}

/** Mirrors auth-service UserSummaryResponse DTO */
export interface UserSummary {
  userId: number;
  username: string;
  email: string;
  firstName: string | null;
  lastName: string | null;
  roleCode: UserRole;
  agencyCode: string | null;
  agencyName: string | null;
}

/** Mirrors auth-service TokenResponse DTO */
export interface TokenResponse {
  accessToken: string;
  expiresIn: number;   // seconds
  tokenType: string;   // "Bearer"
  user: UserSummary;
}

/** Role codes matching auth-service RoleCode enum */
export type UserRole = 'ADMIN' | 'DATA_ENTRY' | 'ANALYST' | 'VIEWER';

/** In-memory auth state held in AuthService */
export interface AuthState {
  accessToken: string;
  expiresAt: number;   // epoch ms
  user: UserSummary;
}
