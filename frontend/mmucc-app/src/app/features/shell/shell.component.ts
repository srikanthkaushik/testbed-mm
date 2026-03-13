import {
  ChangeDetectionStrategy,
  Component,
  HostListener,
  OnInit,
  signal,
  inject,
  computed,
} from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { AsyncPipe } from '@angular/common';
import { AuthService } from '../../core/services/auth.service';
import { UserRole, UserSummary } from '../../core/models/auth.models';

@Component({
  selector: 'app-shell',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [RouterOutlet, RouterLink, RouterLinkActive, AsyncPipe],
  templateUrl: './shell.component.html',
  styleUrl: './shell.component.scss',
})
export class ShellComponent implements OnInit {
  protected readonly authService = inject(AuthService);

  /** Whether the sidebar is currently open. Driven by signal for OnPush compat. */
  readonly sidebarOpen = signal<boolean>(true);

  /** Whether the viewport is considered "mobile" (< 1024 px). */
  readonly isMobile = signal<boolean>(false);

  /** Resolved user from the auth service. */
  readonly currentUser = computed<UserSummary | null>(() => this.authService.currentUser);

  /** Display name shown in the user chip. */
  readonly displayName = computed<string>(() => {
    const u = this.currentUser();
    if (!u) return '';
    const name = [u.firstName, u.lastName].filter(Boolean).join(' ');
    return name || u.email;
  });

  /** Role label for the badge. */
  readonly roleLabel = computed<string>(() => {
    const roleMap: Record<UserRole, string> = {
      ADMIN: 'Admin',
      DATA_ENTRY: 'Data Entry',
      ANALYST: 'Analyst',
      VIEWER: 'Viewer',
    };
    const role = this.currentUser()?.roleCode;
    return role ? roleMap[role] : '';
  });

  /** Whether the Reports link should be enabled. */
  readonly reportsEnabled = computed<boolean>(() => {
    const role = this.currentUser()?.roleCode;
    return role !== 'DATA_ENTRY';
  });

  /** Whether the Admin link should be visible. */
  readonly showAdmin = computed<boolean>(() => {
    return this.currentUser()?.roleCode === 'ADMIN';
  });

  ngOnInit(): void {
    this.checkViewport();
  }

  toggleSidebar(): void {
    this.sidebarOpen.update((v) => !v);
  }

  closeSidebarOnMobile(): void {
    if (this.isMobile()) {
      this.sidebarOpen.set(false);
    }
  }

  async logout(): Promise<void> {
    await this.authService.logout();
  }

  @HostListener('window:resize')
  onResize(): void {
    this.checkViewport();
  }

  private checkViewport(): void {
    const mobile = window.innerWidth < 1024;
    this.isMobile.set(mobile);
    // On desktop the sidebar is always open; on mobile default to closed
    if (!mobile) {
      this.sidebarOpen.set(true);
    }
  }
}
