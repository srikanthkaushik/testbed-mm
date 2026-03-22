import {
  ChangeDetectionStrategy,
  Component,
  inject,
  signal,
} from '@angular/core';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { catchError } from 'rxjs/operators';
import { EMPTY } from 'rxjs';
import { ReportService } from '../../core/services/report.service';
import { AlertComponent } from '../../shared/components/alert/alert.component';

@Component({
  selector: 'app-reports',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, AlertComponent],
  templateUrl: './reports.component.html',
  styleUrl: './reports.component.scss',
})
export class ReportsComponent {
  private readonly reportService = inject(ReportService);
  private readonly fb            = inject(FormBuilder);

  readonly downloading = signal(false);
  readonly errorMsg    = signal('');
  readonly successMsg  = signal('');

  readonly filterForm = this.fb.nonNullable.group({
    dateFrom: [''],
    dateTo:   [''],
    severity: [''],
    county:   [''],
  });

  readonly severityOptions: { code: number; label: string }[] = [
    { code: 1, label: 'Fatal (K)' },
    { code: 2, label: 'Serious Injury (A)' },
    { code: 3, label: 'Minor Injury (B)' },
    { code: 4, label: 'Possible Injury (C)' },
    { code: 5, label: 'PDO / No Injury (O)' },
  ];

  downloadCsv(): void {
    this.downloading.set(true);
    this.errorMsg.set('');
    this.successMsg.set('');

    const raw = this.filterForm.getRawValue();
    const severityNum = raw.severity ? parseInt(raw.severity, 10) : null;

    this.reportService.exportCrashCsv({
      dateFrom:    raw.dateFrom || null,
      dateTo:      raw.dateTo   || null,
      severityCode: severityNum !== null && !isNaN(severityNum) ? severityNum : null,
      countyCode:  null,
    }).pipe(
      catchError((err: unknown) => {
        this.errorMsg.set(err instanceof Error ? err.message : 'Export failed. Please try again.');
        this.downloading.set(false);
        return EMPTY;
      }),
    ).subscribe(blob => {
      this.downloading.set(false);
      const date = new Date().toISOString().slice(0, 10);
      const url  = URL.createObjectURL(blob);
      const a    = document.createElement('a');
      a.href     = url;
      a.download = `crashes-export-${date}.csv`;
      a.click();
      URL.revokeObjectURL(url);
      this.successMsg.set('CSV downloaded successfully.');
    });
  }

  clearFilters(): void {
    this.filterForm.reset();
    this.errorMsg.set('');
    this.successMsg.set('');
  }
}
