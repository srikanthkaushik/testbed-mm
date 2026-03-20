import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { RoleCode, UserPage, UserRoleRequest, UserStatusRequest, UserSummary } from '../models/admin.models';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = '/admin/users';

  listUsers(page: number, size: number, role: RoleCode | '' = ''): Observable<UserPage> {
    let params = new HttpParams()
      .set('page', page.toString())
      .set('size', size.toString());
    if (role) {
      params = params.set('role', role);
    }
    return this.http.get<UserPage>(this.baseUrl, { params });
  }

  updateRole(userId: number, roleCode: RoleCode): Observable<UserSummary> {
    const body: UserRoleRequest = { roleCode };
    return this.http.put<UserSummary>(`${this.baseUrl}/${userId}/role`, body);
  }

  updateStatus(userId: number, active: boolean): Observable<UserSummary> {
    const body: UserStatusRequest = { active };
    return this.http.put<UserSummary>(`${this.baseUrl}/${userId}/status`, body);
  }
}
