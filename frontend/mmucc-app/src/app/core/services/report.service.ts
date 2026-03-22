import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

export interface ReportFilter {
  dateFrom: string | null;
  dateTo:   string | null;
  severityCode: number | null;
  countyCode:   string | null;
}

@Injectable({ providedIn: 'root' })
export class ReportService {
  private readonly http    = inject(HttpClient);
  private readonly baseUrl = environment.reportServiceUrl;

  /**
   * Requests a CSV export from the report-service.
   * Returns a Blob (text/csv) that can be saved to disk.
   */
  exportCrashCsv(filter: ReportFilter): Observable<Blob> {
    let params = new HttpParams();
    if (filter.dateFrom)    params = params.set('dateFrom',    filter.dateFrom);
    if (filter.dateTo)      params = params.set('dateTo',      filter.dateTo);
    if (filter.severityCode !== null && filter.severityCode !== undefined)
      params = params.set('severityCode', filter.severityCode.toString());
    if (filter.countyCode)  params = params.set('countyCode',  filter.countyCode);

    return this.http.get(`${this.baseUrl}/crashes/export`, {
      params,
      responseType: 'blob',
    });
  }
}
