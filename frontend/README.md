# Frontend

## Overview

The MMUCC Crash Reporting System frontend is an **Angular 17** single-page application located in `mmucc-app/`. It is built with standalone components, lazy-loaded routes, and a muted WCAG 2.1 AA–compliant design system. Authentication is handled via **Firebase** (Google SSO and email/password) with tokens exchanged at the **auth-service** backend.

---

## Directory Structure

```
frontend/
├── README.md            ← this file
├── mockup/              ← Balsamiq-style HTML wireframes (click-through prototype)
└── mmucc-app/           ← Angular 17 application source
    ├── angular.json
    ├── package.json
    ├── proxy.conf.json  ← dev proxy: /auth → :8081, /crashes → :8082
    ├── tsconfig.json
    └── src/
        ├── index.html
        ├── main.ts
        ├── styles.scss                     ← global design tokens + ADA base styles
        ├── environments/
        │   ├── environment.ts              ← Firebase config placeholder (dev)
        │   └── environment.prod.ts         ← Firebase config placeholder (prod)
        └── app/
            ├── app.component.ts            ← root shell + skip navigation link
            ├── app.config.ts               ← providers, APP_INITIALIZER (session restore)
            ├── app.routes.ts               ← route table (lazy-loaded)
            ├── core/
            │   ├── models/
            │   │   ├── auth.models.ts      ← TS interfaces mirroring auth-service DTOs
            │   │   └── crash.models.ts     ← CrashSummary, CrashFilter, Page<T>
            │   ├── services/
            │   │   ├── firebase-auth.service.ts  ← Firebase v10 modular SDK wrapper
            │   │   ├── auth.service.ts           ← session manager, JWT, auto-refresh
            │   │   └── crash.service.ts          ← GET /crashes with filter/pagination
            │   ├── interceptors/
            │   │   └── auth.interceptor.ts       ← Bearer token + 401 retry
            │   └── guards/
            │       └── auth.guard.ts             ← redirect to /login with returnUrl
            ├── shared/
            │   └── components/
            │       └── alert/
            │           └── alert.component.ts    ← accessible alert/status banner
            └── features/
                ├── auth/
                │   └── login/
                │       ├── login.component.ts    ← Google SSO + email/password logic
                │       ├── login.component.html  ← split-panel, fully annotated ADA
                │       └── login.component.scss  ← muted palette, contrast documented
                ├── shell/
                │   ├── shell.component.ts        ← authenticated layout host
                │   ├── shell.component.html      ← responsive nav + collapsible sidebar
                │   └── shell.component.scss      ← layout, role badge, mobile breakpoints
                └── crashes/
                    ├── crash-list/
                    │   ├── crash-list.component.ts    ← filter/page/sort + URL sync
                    │   ├── crash-list.component.html  ← table, filters, pagination controls
                    │   └── crash-list.component.scss  ← table styling, skeleton shimmer
                    └── crash-detail/
                        ├── crash-detail.component.ts    ← tabbed detail, signals, formatters
                        ├── crash-detail.component.html  ← 4-tab layout with stats strip
                        └── crash-detail.component.scss  ← field grid, vehicle cards, tab bar
```

---

## Getting Started

### Prerequisites

- Node.js 18+
- npm 9+
- A Firebase project with **Authentication** enabled (Google provider + Email/Password provider)

### Installation

```bash
cd frontend/mmucc-app
npm install
```

### Firebase Configuration

Open `src/environments/environment.ts` and replace the placeholder values with your Firebase project settings (found in the Firebase Console under **Project Settings → Your apps → Web app**):

```ts
firebase: {
  apiKey:            'YOUR_API_KEY',
  authDomain:        'YOUR_PROJECT_ID.firebaseapp.com',
  projectId:         'YOUR_PROJECT_ID',
  storageBucket:     'YOUR_PROJECT_ID.appspot.com',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  appId:             'YOUR_APP_ID',
},
```

### Running Locally

Start auth-service (port 8081) and crash-service (port 8082) first, then:

```bash
npm start
# → http://localhost:4200
```

The dev server proxies `/auth` to `http://localhost:8081` and `/crashes` to `http://localhost:8082`, so no CORS configuration is needed during development.

### Production Build

```bash
npm run build:prod
# Output: dist/mmucc-app/
```

---

## Architecture

### Tech Stack

| Concern | Choice |
|---|---|
| Framework | Angular 17 (standalone components, no NgModules) |
| Language | TypeScript 5.4 (strict mode) |
| Styles | SCSS with CSS custom properties |
| Authentication | Firebase JS SDK v10 (modular API) |
| HTTP | Angular `HttpClient` with functional interceptor |
| Routing | Angular Router with lazy loading |
| Forms | Angular Reactive Forms |
| Change detection | `OnPush` throughout |
| Bundler | `@angular-devkit/build-angular:application` (esbuild) |

### Authentication Flow

```
User
 │
 ├─ "Continue with Google" ──► Firebase popup ──► ID token
 │                                                    │
 └─ Email + Password ──► Firebase signIn ──► ID token
                                                      │
                                              POST /auth/login
                                            { firebaseIdToken }
                                                      │
                                            auth-service validates
                                            token with Firebase Admin SDK
                                                      │
                                     ┌────────────────┴──────────────────┐
                               Response body                    Set-Cookie
                           { accessToken,                  mmucc-refresh-token
                             expiresIn,                    (HttpOnly, SameSite=Strict,
                             user }                         Path=/auth/refresh)
                                     └────────────────┬──────────────────┘
                                                       │
                                              Angular stores JWT
                                              in memory (BehaviorSubject)
                                                       │
                                              Auto-refresh timer set
                                              (fires 60 s before expiry)
```

**Token storage:** The JWT access token is held exclusively in memory — never in `localStorage` or `sessionStorage`. The refresh token is an HttpOnly cookie managed entirely by the browser, invisible to JavaScript.

### Route Table

| Path | Component | Guard | Role |
|---|---|---|---|
| `/login` | `LoginComponent` | — | Public |
| `/` | — | — | Redirects to `/crashes` |
| `/crashes` | `CrashListComponent` | `authGuard` | Authenticated |
| `/crashes/:id` | `CrashDetailComponent` | `authGuard` | Authenticated |
| `/dashboard` | `ComingSoonComponent` | `authGuard` | Authenticated |
| `/reports` | `ComingSoonComponent` | `authGuard` | Authenticated |
| `/admin/users` | `ComingSoonComponent` | `authGuard` | Authenticated |
| `**` | — | — | Redirects to `/crashes` |

The `authGuard` redirects unauthenticated users to `/login?returnUrl=<attempted-path>`. After a successful login the user is sent back to the originally requested URL.

### Session Restore on Startup

`APP_INITIALIZER` calls `AuthService.tryRestoreSession()` before the first navigation. This silently POSTs to `/auth/refresh` using the existing HttpOnly cookie. If a valid cookie is present the user lands directly on their intended page; if not, they see the login screen. This prevents a flash-of-login-page for returning users.

### HTTP Interceptor

`authInterceptor` (functional `HttpInterceptorFn`):

1. Skips `/auth/login` and `/auth/refresh` endpoints.
2. Attaches `Authorization: Bearer <token>` to all other requests.
3. On a `401` response, attempts one silent token refresh then retries the original request.
4. If the refresh also fails, propagates the error (triggering logout via the auth service).

---

## Design System

### Color Palette (WCAG 2.1 AA)

All colour values are defined as CSS custom properties in `src/styles.scss`:

| Token | Value | Contrast on white | Usage |
|---|---|---|---|
| `--color-primary` | `#1D4E89` | 8.59:1 ✓ AAA | Buttons, links, brand |
| `--color-text` | `#1A1A1A` | 15.3:1 ✓ AAA | Headings |
| `--color-text-body` | `#2D2D2D` | 11.9:1 ✓ AAA | Body copy |
| `--color-text-muted` | `#545454` | 7.1:1 ✓ AAA | Secondary labels |
| `--color-text-subtle` | `#767676` | 4.54:1 ✓ AA | Captions, placeholders |
| `--color-error` | `#B91C1C` | 5.80:1 ✓ AA | Errors, required markers |
| `--color-success` | `#166534` | 6.16:1 ✓ AA | Success states |
| `--color-bg` | `#F3F1EE` | — | Page background (warm off-white) |

### ADA / WCAG 2.1 AA Compliance

| Requirement | Implementation |
|---|---|
| **Contrast ratios** | All foreground/background pairs documented and verified ≥ 4.5:1 |
| **Focus indicators** | 3px solid `#1558B0` focus ring, `:focus-visible` only, never `outline: none` |
| **Form labels** | Every `<input>` has an explicit `<label for="...">` — no placeholder substitutes |
| **Error association** | `aria-invalid="true"` + `aria-describedby` pointing to error `<span>` on every input |
| **Error announcements** | Error `<span>` has `role="alert"` + `aria-live="polite"` |
| **Loading states** | `aria-busy` on buttons; spinner text hidden visually but announced via `.sr-only` |
| **Password toggle** | `aria-pressed` state changes; `aria-label` updates between "Show password" / "Hide password" |
| **Skip navigation** | `.skip-link` in `AppComponent`; visible on focus, links to `#main-content` |
| **Zoom** | No `maximum-scale` or `user-scalable=no` restriction in `<meta viewport>` |
| **Semantic HTML** | `<main>`, `<header>`, `<footer>`, `<nav>`, `<section>`, `<aside>` used correctly |
| **Colour independence** | Errors conveyed by border colour + icon + text label (never colour alone) |
| **Heading hierarchy** | Single `<h1>` per page; logical `h2`/`h3` nesting |

---

## Sprint Plan

| Sprint | Frontend Scope | Status |
|---|---|---|
| **Sprint 1** | Routing scaffold, core services, login page (Google SSO + email/password), end-to-end auth verified | ✅ Complete |
| **Sprint 2** | Authenticated shell (responsive nav + collapsible sidebar, role-aware links, logout) | ✅ Complete |
| **Sprint 3** | Crash list with date/county filters, sort, pagination, URL state sync, skeleton shimmer | ✅ Complete |
| **Sprint 4** | Multi-step crash entry form (C1–C27 MMUCC fields) | 🔲 Not started |
| **Sprint 5** | Crash detail view (tabbed: overview, vehicles, roadway, audit log) | ✅ Complete |
| **Sprint 6** | Vehicle entry modal (V1–V24), roadway upsert form | 🔲 Not started |
| **Sprint 7** | Admin: user management, role assignment | 🔲 Not started |
| **Sprint 8** | Reports, CSV export, analytics charts | 🔲 Not started |

### Sprint 1 — Completed

- [x] Angular 17 project bootstrapped (standalone components, `OnPush`, esbuild)
- [x] Lazy-loaded route table with `authGuard` and `returnUrl` support
- [x] `FirebaseAuthService` — Firebase JS SDK v10 modular wrapper (Google popup + email/password)
- [x] `AuthService` — in-memory JWT storage, auto-refresh timer (60 s before expiry), `APP_INITIALIZER` session restore
- [x] `authInterceptor` — Bearer token attachment, silent 401 → refresh → retry cycle
- [x] Login page — ADA/WCAG 2.1 AA compliant, Google SSO + email/password, muted color scheme
- [x] Dev proxy configured (`/auth` → `:8081`, `/crashes` → `:8082`)
- [x] End-to-end authentication verified: Google sign-in → Firebase ID token → auth-service JWT → crash-service requests authorized

### Sprint 2 — Completed

- [x] `ShellComponent` — authenticated layout host wrapping all protected routes
- [x] Responsive sidebar — collapsible on mobile (< 1024 px), always-open on desktop
- [x] Top navigation bar — app title, sidebar toggle button, user display name + role badge, logout
- [x] Role-aware nav links — Reports hidden from `DATA_ENTRY`; Admin section visible to `ADMIN` only
- [x] Active link highlighting via `RouterLinkActive`
- [x] `OnPush` + Angular signals throughout; `HostListener` for window resize

### Sprint 3 — Completed

- [x] `CrashListComponent` — paginated table of crash records from `GET /crashes`
- [x] `CrashService` — typed `HttpClient` wrapper with `HttpParams` filter builder
- [x] `crash.models.ts` — `CrashSummary`, `CrashFilter`, `Page<T>` interfaces mirroring crash-service DTOs
- [x] Filter panel — date range (from/to) and county inputs; Apply / Clear buttons
- [x] Sort toggle on crash date column (asc/desc)
- [x] Page size selector (10 / 20 / 50); previous/next pagination controls
- [x] "Showing X–Y of Z records" label driven by computed signals
- [x] URL query-param sync — filter + page + sort state survives browser back/forward and bookmarks
- [x] Skeleton shimmer rows shown during load; `AlertComponent` shown on fetch error
- [x] Field names corrected to match backend DTOs (`crashIdentifier`, `cityPlaceName`, `numFatalities`, `numMotorVehicles`, `crashSeverityCode`)
- [x] Severity column added to list; Injuries/Persons columns removed (not in summary response); rows clickable

### Sprint 5 — Completed

- [x] `CrashDetailComponent` — tabbed read-only detail page at `/crashes/:id`
- [x] Stats strip — fatalities, injured, vehicles, persons counts from the detail response
- [x] **Overview tab** — identification, location (lat/lng, county, city, route), collision conditions (weather codes, surface codes, light, manner), junction/work zone fields
- [x] **Vehicles tab** — card per vehicle: unit number, make/model/year, speed limit, maneuver, damage extent/contact, tow status, sequence-of-events list, damage areas list
- [x] **Roadway tab** — functional class, NHS membership, AADT, lane width, grade, curve radius, pavement markings, lighting
- [x] **Audit tab** — created by/at, last modified by/at, crash ID
- [x] Back link to crash list; spinner during load; `AlertComponent` on fetch error
- [x] `CrashDetail`, `VehicleDetail`, `RoadwayDetail`, `ChildCode`, `TrafficControl` TypeScript interfaces added to `crash.models.ts`
- [x] `CrashService.getCrash(id)` — typed `GET /crashes/{id}`
- [x] View button in crash list enabled; rows now navigate directly to detail on click
