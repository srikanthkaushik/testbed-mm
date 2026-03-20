import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuditLogEntry, CrashDetail, CrashFilter, CrashRequest, CrashSummary, FatalSection, FatalSectionRequest, NonMotorist, NonMotoristRequest, Page, PersonDetail, PersonRequest, VehicleDetail, VehicleRequest } from '../models/crash.models';

@Injectable({ providedIn: 'root' })
export class CrashService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.crashServiceUrl;

  getCrashes(filter: CrashFilter): Observable<Page<CrashSummary>> {
    let params = new HttpParams()
      .set('page', filter.page.toString())
      .set('size', filter.size.toString())
      .set('sort', filter.sort);

    if (filter.dateFrom !== null) params = params.set('dateFrom', filter.dateFrom);
    if (filter.dateTo !== null) params = params.set('dateTo', filter.dateTo);
    if (filter.countyCode !== null) params = params.set('countyCode', filter.countyCode.toString());
    if (filter.minFatalities !== null) params = params.set('minFatalities', filter.minFatalities.toString());

    return this.http.get<Page<CrashSummary>>(this.baseUrl, { params });
  }

  getCrash(id: number): Observable<CrashDetail> {
    return this.http.get<CrashDetail>(`${this.baseUrl}/${id}`);
  }

  // ── Vehicle endpoints ──────────────────────────────────────────────────

  getVehicle(crashId: number, vehicleId: number): Observable<VehicleDetail> {
    return this.http.get<VehicleDetail>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}`);
  }

  createVehicle(crashId: number, request: VehicleRequest): Observable<VehicleDetail> {
    return this.http.post<VehicleDetail>(`${this.baseUrl}/${crashId}/vehicles`, request);
  }

  updateVehicle(crashId: number, vehicleId: number, request: VehicleRequest): Observable<VehicleDetail> {
    return this.http.put<VehicleDetail>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}`, request);
  }

  deleteVehicle(crashId: number, vehicleId: number): Observable<void> {
    return this.http.delete<void>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}`);
  }

  // ── Person endpoints ───────────────────────────────────────────────────

  getPerson(crashId: number, vehicleId: number, personId: number): Observable<PersonDetail> {
    return this.http.get<PersonDetail>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}/persons/${personId}`);
  }

  createPerson(crashId: number, vehicleId: number, request: PersonRequest): Observable<PersonDetail> {
    return this.http.post<PersonDetail>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}/persons`, request);
  }

  updatePerson(crashId: number, vehicleId: number, personId: number, request: PersonRequest): Observable<PersonDetail> {
    return this.http.put<PersonDetail>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}/persons/${personId}`, request);
  }

  upsertFatalSection(crashId: number, vehicleId: number, personId: number, request: FatalSectionRequest): Observable<FatalSection> {
    return this.http.put<FatalSection>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}/persons/${personId}/fatal`, request);
  }

  upsertNonMotorist(crashId: number, vehicleId: number, personId: number, request: NonMotoristRequest): Observable<NonMotorist> {
    return this.http.put<NonMotorist>(`${this.baseUrl}/${crashId}/vehicles/${vehicleId}/persons/${personId}/non-motorist`, request);
  }

  // ── Crash endpoints ────────────────────────────────────────────────────

  createCrash(request: CrashRequest): Observable<CrashDetail> {
    return this.http.post<CrashDetail>(this.baseUrl, request);
  }

  updateCrash(id: number, request: CrashRequest): Observable<CrashDetail> {
    return this.http.put<CrashDetail>(`${this.baseUrl}/${id}`, request);
  }

  getAuditLog(id: number): Observable<AuditLogEntry[]> {
    return this.http.get<AuditLogEntry[]>(`${this.baseUrl}/${id}/audit`);
  }
}
