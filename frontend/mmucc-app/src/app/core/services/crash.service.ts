import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { CrashDetail, CrashFilter, CrashSummary, Page } from '../models/crash.models';

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
}
