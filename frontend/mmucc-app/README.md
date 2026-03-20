# mmucc-app — Angular Frontend

Angular 18 single-page application for the MMUCC v5 Crash Reporting System.

---

## Status — March 2026

| Phase | Scope | Status |
|---|---|---|
| Phase 1 | Login, authenticated shell, crash list | ✅ Complete |
| Phase 2–3 | Crash detail — all 115 MMUCC elements across 5 tabs | ✅ Complete |
| Phase 4 | Crash entry form (C1–C27) | ✅ Complete |
| Phase 5 | Vehicle entry form (V1–V24) | ✅ Complete |
| Phase 6 | Person entry form (P1–P27) with conditional Fatal / Non-Motorist sub-sections | ✅ Complete |
| Phase 7 | Roadway entry form (R1–R16) | ✅ Complete |
| Phase 7a | Vehicle Automation form (DV1) | ✅ Complete |
| Phase 7b | Large Vehicle / HazMat form (LV1–LV11) | ✅ Complete |
| Phase 7c | Delete crash / vehicle / person with inline confirmation | ✅ Complete |
| Phase 8 | Dashboard (stat cards, recent crashes table) | ✅ Complete |
| Phase 8a | Admin user management (user list, role filter, inline role editing) | ✅ Complete |
| Phase 9 | Reports / CSV export (report-service not yet built) | 🔲 Not started |

---

## Prerequisites

- Node.js 20+
- Angular CLI 18: `npm install -g @angular/cli`
- Backend services running (auth-service on 8081, crash-service on 8082) — see [`../../backend/README.md`](../../backend/README.md)

---

## Local Development

```bash
npm install
ng serve            # http://localhost:4200
```

API calls are proxied via `proxy.conf.json` (active during `ng serve`):
- `/auth` → `http://localhost:8081` (auth-service)
- `/admin` → `http://localhost:8081` (auth-service admin endpoints)
- `/api` → `http://localhost:8082` (crash-service; `/api` prefix is stripped before forwarding)

### Build

```bash
ng build                              # production
ng build --configuration development  # development (unminified)
```

---

## Architecture

### Key Decisions

| Decision | Choice |
|---|---|
| Component model | Standalone (no NgModules) |
| State management | Angular Signals (`signal`, `computed`) |
| Change detection | `OnPush` everywhere |
| Routing | Lazy-loaded standalone components |
| HTTP | `HttpClient` via `provideHttpClient(withInterceptors([...]))` |
| Auth | `authInterceptor` attaches `Authorization: Bearer <token>` from in-memory JWT (never localStorage) |
| Forms | `ReactiveFormsModule` with `FormBuilder.nonNullable` |
| Styles | Component-scoped SCSS + global CSS custom properties (design tokens) |

### Project Structure

```
src/app/
├── core/
│   ├── guards/
│   │   └── auth.guard.ts              Route guard — redirects to /login if no token
│   ├── interceptors/
│   │   └── auth.interceptor.ts        Attaches Bearer token to all API requests
│   ├── models/
│   │   ├── crash.models.ts            TypeScript interfaces for all crash-service DTOs
│   │   │                              (CrashSummary, CrashDetail, VehicleDetail,
│   │   │                               PersonDetail, all Request types, Page<T>, …)
│   │   ├── admin.models.ts            UserSummary, RoleCode, ROLE_LABELS, ALL_ROLES
│   │   └── mmucc-lookup.ts            Record<number, string> maps for all MMUCC
│   │                                  coded-value fields (50+ lookup maps)
│   └── services/
│       ├── auth.service.ts            Firebase login, token storage, logout
│       ├── crash.service.ts           All crash / vehicle / person / roadway API calls
│       └── admin.service.ts           User list, role update (admin endpoints)
│
├── features/
│   ├── auth/
│   │   └── login/                         Firebase SSO + email/password login
│   ├── shell/                             App shell — nav, sidebar, outlet
│   ├── dashboard/                         Stat cards + recent crashes table
│   ├── admin/
│   │   └── admin-users/                  User list, role filter, inline role editing
│   └── crashes/
│       ├── crash-list/                    Crash list with filters, sort, pagination, delete
│       ├── crash-detail/                  5-tab read-only detail (all 115 fields), delete
│       ├── crash-form/                    Create / edit crash (C1–C27)
│       ├── vehicle-form/                  Add / edit vehicle (V1–V24)
│       ├── person-form/                   Add / edit person (P1–P27, conditional F/NM)
│       ├── roadway-form/                  Upsert roadway (R1–R16)
│       ├── vehicle-automation-form/       Upsert automation data (DV1)
│       └── large-vehicle-form/            Upsert large vehicle / HazMat (LV1–LV11)
│
└── shared/
    └── components/
        └── alert/                     Reusable error/info/success alert banner
```

### Design Tokens (CSS Custom Properties)

Defined in `src/styles.scss` and available globally:

| Token | Usage |
|---|---|
| `--color-primary` | Brand blue — buttons, links, focus rings |
| `--color-surface` | Card / panel background |
| `--color-bg` | Page background |
| `--color-border` | All borders |
| `--color-text` / `--color-text-muted` | Body / secondary text |
| `--color-danger` | Error states, fatal badge |
| `--space-1` … `--space-8` | 4px-based spacing scale |
| `--text-xs` … `--text-2xl` | Type scale |
| `--radius-sm` / `--radius-md` | Border radii |
| `--font-mono` | Monospace font for codes, IDs |

---

## Route Map

| Path | Component | Description |
|---|---|---|
| `/login` | `LoginComponent` | Firebase login page (public) |
| `/crashes` | `CrashListComponent` | Paginated crash list with filters |
| `/crashes/new` | `CrashFormComponent` | Create a new crash record |
| `/crashes/:id` | `CrashDetailComponent` | Tabbed crash detail (read-only) |
| `/crashes/:id/edit` | `CrashFormComponent` | Edit an existing crash |
| `/crashes/:crashId/vehicles/new` | `VehicleFormComponent` | Add a vehicle to a crash |
| `/crashes/:crashId/vehicles/:vehicleId/edit` | `VehicleFormComponent` | Edit a vehicle |
| `/crashes/:crashId/vehicles/:vehicleId/persons/new` | `PersonFormComponent` | Add a person to a vehicle |
| `/crashes/:crashId/vehicles/:vehicleId/persons/:personId/edit` | `PersonFormComponent` | Edit a person |
| `/crashes/:crashId/roadway/edit` | `RoadwayFormComponent` | Create or edit roadway data |
| `/crashes/:crashId/vehicles/:vehicleId/automation` | `VehicleAutomationFormComponent` | Create or edit automation data |
| `/crashes/:crashId/vehicles/:vehicleId/large-vehicle` | `LargeVehicleFormComponent` | Create or edit large vehicle / HazMat data |
| `/dashboard` | `DashboardComponent` | Summary stat cards + recent crashes |
| `/reports` | *(coming soon)* | Filtered exports |
| `/admin/users` | `AdminUsersComponent` | User list + inline role editing (ADMIN only) |

> Route order matters: `crashes/new` and `crashes/:crashId/vehicles/new` are declared before their parameterized siblings to prevent the literal string `"new"` from matching a numeric `:id` or `:crashId`.

---

## API Proxy

`proxy.conf.json` forwards `/crashes/**` and `/auth/**` to `http://localhost:8082` and `http://localhost:8081` respectively during `ng serve`. In production, an API gateway or Nginx handles routing.

---

## MMUCC Lookup Maps (`mmucc-lookup.ts`)

All coded-value fields are rendered as `N — Description` using pre-built `Record<number, string>` maps. Example:

```typescript
import { CRASH_TYPE, LIGHT_CONDITION } from '../core/models/mmucc-lookup';

label(crash.crashTypeCode, CRASH_TYPE)       // "1 — Single Vehicle"
label(crash.lightConditionCode, LIGHT_CONDITION) // "1 — Daylight"
```

Over 50 lookup maps are defined covering all 8 MMUCC sections. The form components also use these maps to build `<select>` option lists.

---

## Forms Architecture

All entry forms (`CrashFormComponent`, `VehicleFormComponent`, `PersonFormComponent`, `RoadwayFormComponent`, `VehicleAutomationFormComponent`, `LargeVehicleFormComponent`) follow the same pattern:

1. **Mode detection** — `crashId` / `vehicleId` from route params; `null` = create, non-null = edit
2. **Pre-load** — in edit mode, fetch the existing record and `patchValue()` the form
3. **Scalar fields** — `FormBuilder.nonNullable.group()` with typed `number | null` and `string` controls
4. **Multi-value fields** — `signal<Set<number>>` for checkbox grids (weather, surface, traffic controls, damage areas, etc.)
5. **`buildRequest()`** — converts raw form values + signals into the typed request DTO; empty strings → `null`; `Set<number>` → `{ sequenceNum, code }[]`
6. **Submit** — `POST` (create) or `PUT` (edit) via `CrashService`; on success navigate to detail view

---

## Coding Conventions

- All components use `ChangeDetectionStrategy.OnPush`
- Subscriptions are managed with `takeUntilDestroyed(this.destroyRef)` — no manual `unsubscribe()`
- `inject()` preferred over constructor injection
- Template control flow uses Angular 17+ `@if` / `@for` / `@else` syntax (no `*ngIf` / `*ngFor`)
- No `NgModules` — all imports declared directly on standalone components
