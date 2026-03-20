import { Page } from './crash.models';

export type RoleCode = 'ADMIN' | 'DATA_ENTRY' | 'ANALYST' | 'VIEWER';

export interface UserSummary {
  userId:     number;
  username:   string;
  email:      string;
  firstName:  string;
  lastName:   string;
  roleCode:   RoleCode;
  agencyCode: string | null;
  agencyName: string | null;
}

export type UserPage = Page<UserSummary>;

export interface UserRoleRequest {
  roleCode: RoleCode;
}

export interface UserStatusRequest {
  active: boolean;
}

export const ROLE_LABELS: Record<RoleCode, string> = {
  ADMIN:      'Admin',
  DATA_ENTRY: 'Data Entry',
  ANALYST:    'Analyst',
  VIEWER:     'Viewer',
};

export const ALL_ROLES: RoleCode[] = ['ADMIN', 'DATA_ENTRY', 'ANALYST', 'VIEWER'];
