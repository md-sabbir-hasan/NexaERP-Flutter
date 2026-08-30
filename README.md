# NexaERP Mobile

A Flutter companion app for **NexaERP** — a full-stack ERP system built with Spring Boot 4 + Angular. This app consumes the same REST API as the web frontend and mirrors its backend module structure, giving finance/admin users core ERP functionality on Android and iOS.

> Built as part of an IsDB course project. Backend: Spring Boot 4 (Java 21) + MySQL. Web frontend: Angular (standalone, signals). This repo: Flutter mobile client.

---

## Tech Stack

| Layer | Choice |
|---|---|
| State management | Riverpod 2 (`AsyncNotifier`, `NotifierProvider`, `Provider.family`) |
| Networking | Dio + custom JWT auth interceptor (silent refresh on 401) |
| Routing | go_router with `StatefulShellRoute` (persistent bottom-nav tabs) |
| Secure storage | flutter_secure_storage (access/refresh tokens) |
| Charts | fl_chart (budget donut) |
| Date/format | intl |

No `freezed`/code-gen — models are hand-written `fromJson`/`toJson` for simplicity and faster iteration during course development.

---

## Architecture

Feature-first structure. Each feature owns its `data/` (models + repository), `application/` (Riverpod providers), and `presentation/` (screens + widgets) layers.

```
lib/
├── main.dart
├── app/
│   ├── app.dart                # MaterialApp.router root
│   ├── router.dart              # go_router config, auth guard, StatefulShellRoute
│   ├── shell/
│   │   └── main_shell.dart      # Bottom nav bar + center FAB (quick actions)
│   └── theme/
│       └── app_colors.dart      # Design tokens (single source of truth for colors)
│
├── core/
│   ├── network/
│   │   ├── dio_client.dart          # Dio instance + interceptor wiring
│   │   ├── auth_interceptor.dart    # Attaches JWT, handles 401 → refresh → retry
│   │   ├── api_endpoints.dart       # All endpoint path constants
│   │   └── providers.dart           # dioProvider, secureStorageProvider
│   ├── storage/
│   │   └── secure_storage_service.dart
│   └── models/
│       ├── api_response.dart        # Generic ApiResponse<T> wrapper (matches backend)
│       └── page_response.dart       # Generic Spring Page<T> wrapper
│
├── features/
│   ├── auth/                # Login, JWT/session state
│   ├── dashboard/           # Home screen — cash position, stats, budget donut, activity feed
│   ├── notifications/       # Paginated list, unread badge, mark read/all
│   ├── accounts/            # Chart of Accounts — tree view, search, CRUD
│   ├── journal/             # Journal Entries — multi-line create, post, reverse
│   ├── approvals/           # Maker-checker queue — pending / my requests, approve/reject/return
│   ├── users/                # Users + Roles + Permissions (grouped by module)
│   ├── expense/             # Pay Now / Pay Later, budget warnings, post/cancel
│   ├── invoice/             # Customer billing — line items, discount/VAT, post/cancel
│   ├── vendorbill/          # Payable — per-line expense account + TDS, approve → post
│   ├── payment/             # Receive/Make payment — auto (FIFO) or manual allocation
│   ├── creditnote/          # Sales return against a posted invoice (partial qty supported)
│   ├── debitnote/           # Purchase return against a posted vendor bill
│   ├── banking/             # Bank/Cash/Mobile Wallet accounts, transactions, transfers
│   ├── fixedasset/          # Asset register, straight-line/reducing-balance depreciation, disposal
│   ├── reports/             # Trial Balance, P&L, Balance Sheet, Ledger
│   ├── parties/             # Lightweight customer/vendor picker (shared across features)
│   └── more/                 # Profile, logout, secondary navigation
│
└── shared/
    └── widgets/              # NexaTextField, NotificationBell, StatTile, SectionCard, NexaLogo
```

---

## Features Implemented

### Tier 1 — Core
- JWT auth with silent token refresh, secure storage
- Dashboard (custom design — cash hero card, stat grid, budget donut, recent activity)
- Notifications (pagination, unread badge, mark read)
- Chart of Accounts (expandable tree, type/status filter, activate/deactivate)
- Journal Entries (dynamic lines, live debit=credit balance check, post/submit-approval/reverse)
- Approvals (generic maker-checker queue across Journal/Invoice/VendorBill/Payment)
- Users, Roles & Permissions (permission grouped by module, invite-based user creation)

### Tier 2 — Transactions
- Expense (Pay Now/Later toggle, budget-exceed warning banner)
- Invoice (multi-line, discount % + VAT %, live totals, cancel with reason)
- Vendor Bill (per-line expense account + TDS %, two-step approve → post)
- Payment (Receive from customer / Pay to vendor, FIFO auto-allocate or manual per-document allocation)
- Credit Note (against a posted invoice, partial-quantity return)
- Debit Note (against a posted vendor bill, partial-quantity return)

### Tier 3 — Banking & Assets
- Bank Accounts (Cash / Bank / Mobile Wallet, opening balance, activate/deactivate)
- Bank Transactions (credit/debit with contra account, reconcile/void)
- Fund Transfer between accounts
- Fixed Assets (registration with 4 linked accounts, straight-line & reducing-balance depreciation, bulk depreciation run, disposal with gain/loss)

### Tier 5 — Reports
- Trial Balance (as-of date, balanced check)
- Profit & Loss (date range, revenue/expense breakdown, net profit/loss)
- Balance Sheet (as-of date, assets/liabilities/equity, balanced check)
- Ledger (per-account, date range, running balance)

### Not in scope (by design, for this course build)
- Recurring Expense
- Bank Reconciliation (CSV import/matching)
- Cash Flow Statement, Party Statement, Aging, Cost Center report, Budget vs Actual report
- PDF/Excel export from mobile
- Party (Customer/Vendor) full CRUD — only a lightweight picker exists

---

## Getting Started

### Prerequisites
- Flutter SDK ≥ 3.5.0
- The NexaERP Spring Boot backend running locally (default port `8085`)
- MySQL with the NexaERP schema seeded (default super admin: see backend `application.properties`)

### Setup

```bash
flutter pub get
```

Set the API base URL in `lib/core/network/api_endpoints.dart`:

```dart
// Android emulator → host machine
static const String baseUrl = 'http://10.0.2.2:8085/api';

// Chrome / web
static const String baseUrl = 'http://localhost:8085/api';

// Physical device → use your machine's LAN IP
static const String baseUrl = 'http://192.168.x.x:8085/api';
```

### Run

```bash
# Android emulator
flutter run

# Chrome (fixed port avoids CORS mismatch — see Backend Config below)
flutter run -d chrome --web-port=5000
```

### Backend CORS (for web builds)

Add your Flutter web port to `backend/src/main/resources/application.properties`:

```properties
app.cors.allowed-origins=${CORS_ALLOWED_ORIGINS:http://localhost:4200,http://localhost:5000}
```

Restart the Spring Boot app after changing this (CORS config isn't hot-reloadable).

---

## Key Patterns

- **`ApiResponse<T>`** — every backend response follows `{ success, message, data }`; a single generic parser in `core/models/api_response.dart` is reused everywhere.
- **`PageResponse<T>`** — wraps Spring's paginated responses for infinite-scroll lists (Notifications, Approvals).
- **Auth interceptor** — attaches the bearer token to every request except `/auth/login` and `/auth/refresh`; on a 401 it transparently refreshes the token and retries the original request once.
- **Router + Riverpod** — `GoRouter` is created exactly once; auth-state changes trigger `redirect` re-evaluation via a `ChangeNotifier` wired to `ref.listen(authProvider, ...)`, avoiding router/navigator recreation.
- **Cash-equivalent accounts** — the "Pay From" pickers (Expense, Payment, Asset Disposal) only show Chart of Accounts entries flagged `isCashEquivalent = true`; this flag is set per-account in the Accounts module.
- **Account-type filtered pickers** — `showAccountPickerSheet()` accepts an optional `filterType` (e.g. only Expense accounts) and `cashEquivalentOnly` flag, reused across Expense, VendorBill, Payment, and Fixed Asset forms.

---

## Known Gaps / Follow-ups

- Manual payment allocation filters outstanding invoices/bills **client-side** from the already-fetched list; a dedicated `?partyId=&hasDue=true` backend endpoint would scale better for large datasets.
- Editing a user's roles doesn't pre-select their current roles (backend only returns role **names**, not IDs, in `UserResponseDto`) — reselecting from scratch is required on edit.
- `LogInterceptor` in `dio_client.dart` should be gated behind `kDebugMode` before any release build (currently logs full request/response bodies, including tokens).