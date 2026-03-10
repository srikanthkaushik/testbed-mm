import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

/**
 * Root shell component — renders the active route inside <router-outlet>.
 * Layout chrome (nav bar, sidebar) will be added in a future sprint once
 * the authenticated shell is built.
 */
@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet],
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <a class="skip-link" href="#main-content">Skip to main content</a>
    <router-outlet />
  `,
})
export class AppComponent {}
