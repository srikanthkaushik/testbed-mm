import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';
import { CrashFilter, CrashSummary, Page } from '../models/crash.models';

/**
 * Provides access to the crash-service REST API.
 * All HTTP communication goes through the dev proxy → /crashes → :8082
 */
@Injectable({ providedIn: 'root' })
export class CrashService {
  private readonly http = inject(HttpClient);
  private readonly baseUrl = environment.crashServiceUrl;

  /**
   * Fetch a paginated, optionally filtered list of crash summaries.
   * Only non-null filter fields are appended as query parameters.
   */
  getCrashes(filter: CrashFilter): Observable<Page<CrashSummary>> {
    let params = new HttpParams()
      .set('page', filter.page.toString())
      .set('size', filter.size.toString())
      .set('sort', filter.sort);

    if (filter.dateFrom !== null) {
      params = params.set('dateFrom', filter.dateFrom);
    }
    if (filter.dateTo !== null) {
      params = params.set('dateTo', filter.dateTo);
    }
    if (filter.countyCode !== null) {
      params = params.set('countyCode', filter.countyCode.toString());
    }
    if (filter.minFatalities !== null) {
      params = params.set('minFatalities', filter.minFatalities.toString());
    }

    return this.http.get<Page<CrashSummary>>(this.baseUrl, { params });
  }
}
