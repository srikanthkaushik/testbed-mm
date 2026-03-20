import {
  ChangeDetectionStrategy,
  Component,
  DestroyRef,
  OnInit,
  computed,
  inject,
  signal,
} from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { EMPTY, Subject } from 'rxjs';
import { catchError, debounceTime, distinctUntilChanged, switchMap, tap } from 'rxjs/operators';
import { AdminService } from '../../core/services/admin.service';
import { ALL_ROLES, ROLE_LABELS, RoleCode, UserPage, UserSummary } from '../../core/models/admin.models';
import { AlertComponent } from '../../shared/components/alert/alert.component';

const DEFAULT_PAGE_SIZE = 20;

@Component({
  selector: 'app-admin-users',
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ReactiveFormsModule, AlertComponent],
  templateUrl: './admin-users.component.html',
  styleUrl: './admin-users.component.scss',
})
export class AdminUsersComponent implements OnInit {
  private readonly adminService = inject(AdminService);
  private readonly fb           = inject(FormBuilder);
  private readonly destroyRef   = inject(DestroyRef);

  // ── State ──────────────────────────────────────────────────────────────
  readonly loading     = signal(false);
  readonly errorMsg    = signal('');
  readonly page        = signal<UserPage | null>(null);
  readonly currentPage = signal(0);
  readonly pageSize    = signal(DEFAULT_PAGE_SIZE);

  /** userId currently being edited for role; null = none */
  readonly editingRoleId  = signal<number | null>(null);
  /** pending role selection while editing */
  readonly pendingRole    = signal<RoleCode | null>(null);
  readonly roleSaving     = signal(false);
  readonly roleError      = signal('');

  /** userId whose status toggle is in progress; null = none */
  readonly togglingStatusId = signal<number | null>(null);

  // ── Filter form ───────────────────────────────────────────────────────
  readonly filterForm = this.fb.nonNullable.group({ role: [''] });

  // ── Derived ───────────────────────────────────────────────────────────
  readonly rangeStart = computed(() => {
    const p = this.page();
    if (!p || p.totalElements === 0) return 0;
    return p.number * p.size + 1;
  });

  readonly rangeEnd = computed(() => {
    const p = this.page();
    if (!p) return 0;
    return Math.min(p.number * p.size + p.size, p.totalElements);
  });

  readonly skeletonRows = [0, 1, 2, 3, 4];
  readonly allRoles = ALL_ROLES;
  readonly roleLabels = ROLE_LABELS;

  // ── Fetch trigger ─────────────────────────────────────────────────────
  private readonly fetch$ = new Subject<void>();

  ngOnInit(): void {
    this.fetch$.pipe(
      tap(() => { this.loading.set(true); this.errorMsg.set(''); }),
      debounceTime(150),
      switchMap(() =>
        this.adminService.listUsers(
          this.currentPage(),
          this.pageSize(),
          (this.filterForm.value.role as RoleCode | '') ?? '',
        ).pipe(
          catchError(() => {
            this.errorMsg.set('Failed to load users. Please try again.');
            this.loading.set(false);
            return EMPTY;
          }),
        )
      ),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(result => {
      this.page.set(result);
      this.loading.set(false);
    });

    this.filterForm.valueChanges.pipe(
      debounceTime(200),
      distinctUntilChanged(),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(() => {
      this.currentPage.set(0);
      this.fetch$.next();
    });

    this.fetch$.next();
  }

  goToPage(n: number): void {
    this.currentPage.set(n);
    this.fetch$.next();
  }

  startEditRole(user: UserSummary): void {
    this.editingRoleId.set(user.userId);
    this.pendingRole.set(user.roleCode);
    this.roleError.set('');
  }

  cancelEditRole(): void {
    this.editingRoleId.set(null);
    this.pendingRole.set(null);
  }

  saveRole(userId: number): void {
    const role = this.pendingRole();
    if (!role) return;
    this.roleSaving.set(true);
    this.roleError.set('');

    this.adminService.updateRole(userId, role).pipe(
      catchError(() => {
        this.roleError.set('Failed to update role.');
        this.roleSaving.set(false);
        return EMPTY;
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(updated => {
      // patch user in local page data
      const p = this.page();
      if (p) {
        this.page.set({
          ...p,
          content: p.content.map(u => u.userId === userId ? updated : u),
        });
      }
      this.roleSaving.set(false);
      this.editingRoleId.set(null);
      this.pendingRole.set(null);
    });
  }

  toggleStatus(user: UserSummary): void {
    this.togglingStatusId.set(user.userId);
    this.adminService.updateStatus(user.userId, !user.active).pipe(
      catchError(() => {
        this.togglingStatusId.set(null);
        return EMPTY;
      }),
      takeUntilDestroyed(this.destroyRef),
    ).subscribe(updated => {
      const p = this.page();
      if (p) {
        this.page.set({
          ...p,
          content: p.content.map(u => u.userId === user.userId ? updated : u),
        });
      }
      this.togglingStatusId.set(null);
    });
  }

  fullName(u: UserSummary): string {
    return [u.firstName, u.lastName].filter(Boolean).join(' ') || u.username;
  }

  roleBadgeClass(role: RoleCode): string {
    const map: Record<RoleCode, string> = {
      ADMIN:      'badge--danger',
      DATA_ENTRY: 'badge--info',
      ANALYST:    'badge--warning',
      VIEWER:     'badge--neutral',
    };
    return map[role] ?? 'badge--neutral';
  }
}
