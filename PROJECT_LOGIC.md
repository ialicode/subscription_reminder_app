# PROJECT LOGIC DOCUMENTATION

## 1. Project Overview

### What the application does
This project is a Flutter mobile app (POC) for tracking personal subscriptions (for example streaming, bills, gym, education services). Users can register, log in, add subscriptions, edit them, mark them inactive, or delete them.

### What problem it solves
It helps users avoid losing track of recurring payments by keeping subscription records in one place and calculating current status (Active, Expiring Soon, Expired, Inactive).

### Who would use it
Anyone who pays for recurring services and wants a simple local tracker without backend setup.

### Main features
- Local registration/login/logout
- Protected dashboard for authenticated users
- Add/edit/delete subscription entries
- Mark subscription inactive/active
- Dashboard counters and cost summary
- Status-based filtering

---

## 2. Technology Stack

Technologies found in the codebase and their role:

- **Dart**: Main programming language.
- **Flutter** (`lib/main.dart`): UI framework and app runtime.
- **flutter_bloc**: State management using `AuthBloc` and `SubscriptionBloc`.
- **equatable**: Value-based equality for models/events/states.
- **shared_preferences**: Local persistence for users, session (`currentUser`), and subscriptions.
- **intl**: Date/currency formatting in dashboard/details UI.
- **uuid**: Unique IDs for user and subscription records.
- **google_fonts**: Poppins text theme (`lib/core/theme.dart`).
- **flutter_native_splash / flutter_launcher_icons**: App launch and icon configuration via `pubspec.yaml`.

### Not present in implemented runtime logic
- No backend server
- No REST/GraphQL API routes
- No external database service (Firebase/SQL/etc.)
- No environment-variable-based runtime config in `lib/`

---

## 3. Project Architecture

High-level structure:

- **`lib/main.dart`**
  - App entry point.
  - Initializes `SharedPreferences`.
  - Creates `LocalStorageRepository`.
  - Provides `AuthBloc` and `SubscriptionBloc`.
  - Switches home screen based on auth state.

- **`lib/core/`**
  - `constants.dart`: storage keys and default categories.
  - `theme.dart`: global app theme/colors/typography.

- **`lib/data/models/`**
  - `user.dart`: user entity + JSON conversion.
  - `subscription.dart`: subscription entity + status computation.

- **`lib/data/repositories/local_storage_repository.dart`**
  - Central data access layer for auth and subscription persistence.
  - Converts models <-> JSON and stores strings in `SharedPreferences`.

- **`lib/features/auth/`**
  - Bloc files: auth events/states/business flow.
  - UI files: login and registration forms with validation.

- **`lib/features/subscriptions/`**
  - Bloc files: load/add/update/delete/filter flows.
  - UI files: dashboard, add/edit form, details view.

- **Platform folders (`android/`, `ios/`, `web/`)**
  - Platform runner/configuration generated for Flutter app packaging and launch.

---

## 4. How the Application Works

Typical runtime workflow:

1. App starts in `main.dart`, loads local storage, creates repository/blocs.
2. `AuthBloc` receives `CheckAuthRequested`.
3. If a `currentUser` exists in local storage, app opens dashboard; otherwise login screen opens.
4. User registers or logs in from auth screens.
5. On success, `Authenticated(user)` state is emitted.
6. Dashboard reads user from `AuthBloc` and dispatches `LoadSubscriptions(user.id)`.
7. `SubscriptionBloc` fetches only that user’s subscriptions from repository.
8. UI renders summary cards, filters, and list based on bloc state.
9. Add/edit/details screens dispatch update events back to `SubscriptionBloc`.
10. Repository persists new JSON data in local storage.
11. Bloc reloads subscriptions and dashboard refreshes with updated computed statuses/counters.

---

## 5. Core Logic (Most Important)

### A) App bootstrap + route gate
- **Name:** `main`, `MyApp.build`
- **File:** `lib/main.dart`
- **Purpose:** Initialize dependencies and gate access by auth state.
- **Input:** Existing storage state (`SharedPreferences` values).
- **What happens internally:** Creates repository; injects blocs; uses `BlocBuilder<AuthBloc, AuthState>` to choose loading/login/dashboard.
- **Output:** Correct first screen for authenticated vs unauthenticated user.
- **Why it is important:** It is the central dependency wiring and access control entry point.

### B) Auth session check
- **Name:** `_onCheckAuthRequested`
- **File:** `lib/features/auth/bloc/auth_bloc.dart`
- **Purpose:** Restore previous login session.
- **Input:** `CheckAuthRequested` event.
- **What happens internally:** Reads `currentUser` from repository; emits `Authenticated` or `Unauthenticated`.
- **Output:** Session state used by root screen gate.
- **Why it is important:** Enables persistent login between app launches.

### C) Registration flow with duplicate email guard
- **Name:** `_onRegisterRequested`
- **File:** `lib/features/auth/bloc/auth_bloc.dart`
- **Purpose:** Create user and automatically sign in.
- **Input:** First name, last name, email, password, gender.
- **What happens internally:** Checks email uniqueness via repository; creates `User` with UUID; saves user; logs in immediately; emits auth state or error.
- **Output:** `Authenticated`, `Unauthenticated`, or `AuthError`.
- **Why it is important:** Implements onboarding and prevents duplicate accounts.

### D) Login verification
- **Name:** `login`
- **File:** `lib/data/repositories/local_storage_repository.dart`
- **Purpose:** Validate credentials against stored users.
- **Input:** Email + password.
- **What happens internally:** Loads users from local JSON; finds matching email/password; stores matched user in `currentUser`.
- **Output:** `User?` (null if invalid credentials).
- **Why it is important:** Core authentication mechanism for this backend-less POC.

### E) Subscription status algorithm
- **Name:** `status` getter
- **File:** `lib/data/models/subscription.dart`
- **Purpose:** Determine lifecycle state from dates and inactive flag.
- **Input:** `isInactive` and `expiryOrRenewalDate`.
- **What happens internally:** 
  - Returns `inactive` first if manually archived.
  - Compares normalized date with today.
  - Expired if before today.
  - Expiring soon if within 3 days.
  - Otherwise active.
- **Output:** `SubscriptionStatus` enum value.
- **Why it is important:** Drives dashboard counts, filters, tags, and user decisions.

### F) Subscription filtering engine
- **Name:** `_emitFiltered`, `_onFilterSubscriptions`
- **File:** `lib/features/subscriptions/bloc/subscription_bloc.dart`
- **Purpose:** Apply UI-selected filter to in-memory subscription list.
- **Input:** `_allSubscriptions`, current filter (`All/Active/Expiring soon/Expired`).
- **What happens internally:** Switch statement selects subset by computed status; emits `SubscriptionsLoaded(filtered, filter: ...)`.
- **Output:** Filtered list for dashboard rendering.
- **Why it is important:** Converts raw records into actionable views for users.

### G) Add/Edit form validation and save
- **Name:** Submit handler in `ElevatedButton.onPressed`
- **File:** `lib/features/subscriptions/ui/add_edit_subscription_screen.dart`
- **Purpose:** Validate and persist subscription data.
- **Input:** Form fields (name/category/dates/amount/notes).
- **What happens internally:** Validates required fields, amount >= 0, expiry not before start; builds `Subscription`; dispatches add/update event.
- **Output:** New or updated stored subscription + navigation back.
- **Why it is important:** Prevents invalid business data from entering persistence.

### H) Dashboard summary aggregation
- **Name:** `_buildSummaryCards`
- **File:** `lib/features/subscriptions/ui/dashboard_screen.dart`
- **Purpose:** Compute and display business summary metrics.
- **Input:** Current `SubscriptionsLoaded` state.
- **What happens internally:** Counts active+expiringSoon as active subscriptions, sums their amounts, separately counts expiringSoon renewals.
- **Output:** Total active cost, active count, upcoming renewals count.
- **Why it is important:** Converts list data into quick financial insight.

---

## 6. Data Flow

### Authentication flow
`Login/Registration Form Input`  
↓  
`AuthEvent (LoginRequested/RegisterRequested)`  
↓  
`AuthBloc`  
↓  
`LocalStorageRepository (getUsers/saveUser/login)`  
↓  
`SharedPreferences JSON`  
↓  
`AuthState (Authenticated / AuthError / Unauthenticated)`  
↓  
`UI screen gate in main.dart`

### Subscription management flow
`Dashboard/Add/Edit/Details user action`  
↓  
`SubscriptionEvent (Load/Add/Update/Delete/Filter)`  
↓  
`SubscriptionBloc`  
↓  
`LocalStorageRepository (getUserSubscriptions/saveSubscription/deleteSubscription)`  
↓  
`SharedPreferences JSON`  
↓  
`SubscriptionsLoaded(filtered list)`  
↓  
`Dashboard list, tags, and summary cards update`

---

## 7. Important Code Examples

### Example 1 — Auth-based home routing (`lib/main.dart`)
```dart
home: BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading || state is AuthInitial) {
      return ...; // splash/loading UI
    } else if (state is Authenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  },
),
```
**What it does:** Selects startup screen from auth state.  
**Why needed:** Enforces protected dashboard access.  
**When it executes:** On app start and every auth state change.

### Example 2 — Subscription status calculation (`lib/data/models/subscription.dart`)
```dart
SubscriptionStatus get status {
  if (isInactive) return SubscriptionStatus.inactive;
  final today = DateTime(now.year, now.month, now.day);
  final expiry = DateTime(expiryOrRenewalDate.year, expiryOrRenewalDate.month, expiryOrRenewalDate.day);
  if (expiry.isBefore(today)) return SubscriptionStatus.expired;
  if (expiry.difference(today).inDays <= 3) return SubscriptionStatus.expiringSoon;
  return SubscriptionStatus.active;
}
```
**What it does:** Maps date/inactive flag to lifecycle status.  
**Why needed:** Powers filters, tags, and summary metrics consistently from one rule set.  
**When it executes:** Whenever status is read in UI/bloc logic.

### Example 3 — Repository persistence pattern (`lib/data/repositories/local_storage_repository.dart`)
```dart
await _prefs.setString(
  AppConstants.subscriptionsKey,
  jsonEncode(subs.map((s) => s.toJson()).toList()),
);
```
**What it does:** Serializes subscriptions and stores them under one key.  
**Why needed:** Keeps data persistent without a backend/database server.  
**When it executes:** On add/update/delete subscription operations.

---

## 8. Presentation-Friendly Explanation

### Project Purpose
This app helps users track recurring subscriptions so they can see what is active, what is expiring soon, and what has already expired. It is designed as a proof of concept with local storage and no backend server.

### How It Works
1. User logs in or registers.
2. App stores session and user data locally.
3. Dashboard loads only that user’s subscriptions.
4. User can add/edit/delete or mark subscriptions inactive.
5. App automatically calculates each subscription’s status from dates and updates the dashboard summaries.

### Main Technologies
- **Flutter:** cross-platform UI app framework.
- **flutter_bloc:** clean event/state flow for auth and subscription logic.
- **shared_preferences:** local persistence for users, session, and subscriptions.
- **intl:** readable date and currency formatting.
- **uuid:** unique IDs for records.

### Most Important Logic
The strongest logic is the status-calculation + filtering pipeline:
1) compute status from dates/inactive flag,  
2) filter by selected state,  
3) aggregate active cost and upcoming renewals for dashboard cards.

### Interesting Technical Features
- Auth state controls top-level navigation.
- Feature-based architecture (`auth`, `subscriptions`).
- Reusable repository for all persistence operations.
- Form validations for email, password, amount, and date consistency.

### Challenges the Code Solves
- Session restoration without backend auth services.
- Multi-user data separation in local storage via `userId`.
- Consistent business-state classification (active/expiring/expired/inactive).

---

## 9. Presentation Slide Suggestions (5–8)

### Slide 1 — Problem & Goal
- **Put on slide:** Subscription tracking problem, POC goal, target users.
- **Say:** “I built a local-first subscription reminder app that helps users avoid missing renewal dates and understand recurring costs quickly.”

### Slide 2 — Architecture Overview
- **Put on slide:** Folder map (`core`, `data`, `features/auth`, `features/subscriptions`).
- **Say:** “The project uses feature-based structure and separates UI, state management, and data persistence.”

### Slide 3 — Authentication Flow
- **Put on slide:** Login/registration flow diagram and auth state transitions.
- **Say:** “AuthBloc handles login/register/logout and controls which screen the user can access.”

### Slide 4 — Subscription Lifecycle Logic
- **Put on slide:** Status rules (Expired, Expiring Soon, Active, Inactive).
- **Say:** “This date-based algorithm is central because multiple UI and business decisions depend on it.”

### Slide 5 — Data Flow End-to-End
- **Put on slide:** Event → Bloc → Repository → SharedPreferences → State → UI.
- **Say:** “Every user action follows the same predictable pipeline, which makes behavior easier to maintain and debug.”

### Slide 6 — Dashboard Intelligence
- **Put on slide:** Summary metrics (active count, upcoming renewals, total active cost).
- **Say:** “The dashboard aggregates filtered subscription data into quick financial indicators.”

### Slide 7 — Limitations & Next Steps
- **Put on slide:** Current POC limits and practical improvements.
- **Say:** “This version is local-only, has no backend/API, and stores passwords in plain text; next step would be secure authentication and remote sync.”

---

## Additional Findings (Unused / Incomplete / Placeholder)

1. **Plain-text password storage** is used in `User` model and local JSON (`lib/data/models/user.dart`, `lib/data/repositories/local_storage_repository.dart`), which is acceptable for a POC but not production-safe.
2. **`test/widget_test.dart` is fully commented out**, so there is effectively no active automated test coverage.
3. **`subscription-reminder-poc-requirements.md` suggests Firebase**, but implemented app uses only local `SharedPreferences`; this requirement is not implemented as written.
4. **No backend/API layer exists**; all data operations are local repository calls.

## Security Note
No secrets were copied into this document. If secrets are added to the project in future, they should be excluded from documentation and moved to secure secret management.
