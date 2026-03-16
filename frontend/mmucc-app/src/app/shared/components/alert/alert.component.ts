import {
  ChangeDetectionStrategy,
  Component,
  Input,
  OnChanges,
} from '@angular/core';
import { CommonModule } from '@angular/common';

export type AlertType = 'error' | 'success' | 'warning' | 'info';

/**
 * Accessible inline alert component.
 *
 * ADA notes:
 *  - role="alert" causes screen readers to announce immediately (assertive).
 *  - role="status" is used for non-critical messages (polite).
 *  - The icon is aria-hidden; the type is conveyed by both colour AND text prefix.
 */
@Component({
  selector: 'app-alert',
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    @if (message) {
      <div
        [attr.role]="type === 'error' || type === 'warning' ? 'alert' : 'status'"
        [attr.aria-live]="type === 'error' ? 'assertive' : 'polite'"
        [class]="'alert alert--' + type"
      >
        <span class="alert__icon" aria-hidden="true">{{ icon }}</span>
        <span class="alert__body">
          <span class="sr-only">{{ srPrefix }}</span>
          <span [innerHTML]="message"></span>
        </span>
        @if (dismissible) {
          <button
            type="button"
            class="alert__dismiss"
            (click)="dismiss()"
            [attr.aria-label]="'Dismiss ' + type + ' message'"
          >
            ✕
          </button>
        }
      </div>
    }
  `,
  styles: [`
    .alert {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      padding: 12px 16px;
      border-radius: var(--radius-md);
      border: 1.5px solid transparent;
      font-size: var(--text-sm);
      line-height: 1.5;
      margin-bottom: var(--space-4);

    }

    .alert--error {
      background: var(--color-error-bg);
      border-color: var(--color-error-border);
      color: var(--color-error);
    }
    .alert--success {
      background: var(--color-success-bg);
      border-color: #A7F3D0;
      color: var(--color-success);
    }
    .alert--warning {
      background: var(--color-warning-bg);
      border-color: #FDE68A;
      color: var(--color-warning);
    }
    .alert--info {
      background: var(--color-primary-light);
      border-color: #BFDBFE;
      color: var(--color-primary);
    }

    .alert__icon {
      font-size: 1rem;
      flex-shrink: 0;
      margin-top: 1px;
    }

    .alert__body {
      flex: 1;
    }

    .alert__dismiss {
      background: none;
      border: none;
      padding: 0 4px;
      line-height: 1;
      font-size: 1rem;
      cursor: pointer;
      color: inherit;
      opacity: 0.7;
      flex-shrink: 0;
      border-radius: var(--radius-sm);

      &:hover { opacity: 1; }
      &:focus-visible {
        outline: 2px solid currentColor;
        outline-offset: 2px;
      }
    }

    .sr-only {
      position: absolute;
      width: 1px; height: 1px;
      padding: 0; margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    }
  `],
})
export class AlertComponent implements OnChanges {
  @Input() message = '';
  @Input() type: AlertType = 'error';
  @Input() dismissible = false;

  icon = '';
  srPrefix = '';

  ngOnChanges(): void {
    const map: Record<AlertType, { icon: string; prefix: string }> = {
      error:   { icon: '⚠',  prefix: 'Error: ' },
      success: { icon: '✓',  prefix: 'Success: ' },
      warning: { icon: '⚠',  prefix: 'Warning: ' },
      info:    { icon: 'ℹ',  prefix: 'Notice: ' },
    };
    this.icon     = map[this.type].icon;
    this.srPrefix = map[this.type].prefix;
  }

  dismiss(): void {
    this.message = '';
  }
}
