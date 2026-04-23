# eTalente Frontend

Flutter app for the eTalente recruitment portal. Covers the sign-in screen
(pixel-matched to the supplied design), a sign-up screen (matched to the live
[etalente.co.za/sign-up](https://etalente.co.za/sign-up) style — outlined
floating-label fields, Talent/Employer toggle, dark-navy CTA), and a Job
Board dashboard (matched to the supplied `job board.jpeg` mock — navy
sidebar, top search/actions bar, filter pills, job cards, Quick Stats +
Featured Talent + Chatbot right rail, floating chat FAB) wired to
`GET /api/jobs`, `GET /api/stats` and `POST /api/assistant/message`.

- **Flutter**: 3.x (tested on stable)
- **State**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Routing**: [`go_router`](https://pub.dev/packages/go_router)
- **HTTP**: `package:http`
- **Targets**: Android + Web

## Quick start

```bash
cd frontend
flutter pub get
flutter analyze
flutter test
```

Run against a locally-running backend (`./mvnw spring-boot:run` in `backend/`):

```bash
# Web (Chrome). Uses http://localhost:8080 by default.
flutter run -d chrome

# Android emulator (emulator-5554). Uses http://10.0.2.2:8080 by default —
# that's the emulator's loopback to the host.
flutter run -d emulator-5554

# Physical Android device / custom host. Override the base URL:
flutter run -d <device-id> \
  --dart-define=API_BASE_URL=http://192.168.1.42:8080
```

## Configuration

| Dart-define       | Default (Android)           | Default (other) | Notes                          |
|-------------------|-----------------------------|-----------------|--------------------------------|
| `API_BASE_URL`    | `http://10.0.2.2:8080`      | `http://localhost:8080` | Backend base URL. No trailing slash. |

Pass with `--dart-define=API_BASE_URL=...` at `flutter run` / `flutter build`.

## Architecture

Feature-first, mirroring the backend:

```
lib/
├── app/                       App-wide wiring
│   ├── app.dart               Root widget (MaterialApp.router)
│   ├── router.dart            go_router config
│   └── theme.dart             ThemeData + colour tokens
├── core/api/                  HTTP plumbing
│   ├── api_client.dart        Thin wrapper over package:http
│   └── api_exception.dart     Typed errors mapped from ApiError envelope
├── features/
│   ├── auth/
│   │   ├── data/              AuthApi, AuthRepository
│   │   ├── domain/            AuthSession, AuthenticatedUser
│   │   ├── application/       AuthController (AsyncNotifier) + providers
│   │   └── presentation/      SignInPage + widgets/
│   ├── jobs/
│   │   ├── data/              JobApi, JobRepository
│   │   ├── domain/            Job, JobPage (mirrors backend PageResponse)
│   │   ├── application/       JobBoardController, JobBoardFilters
│   │   └── presentation/      JobBoardPage + widgets/ (JobCard, FilterPills)
│   ├── stats/                 QuickStatsCard (reads GET /api/stats)
│   └── assistant/             Chatbot card + modal sheet (POST /api/assistant/message)
└── shared/widgets/            Cross-feature widgets (AppSideNav, AppTopBar,
                               DashboardShell, FeaturedTalentCard, AppLogoMark, ...)
```

Rules of thumb:

- Widgets in `presentation/` only read providers; no HTTP, no business logic.
- Repositories in `data/` are plain classes exposed via `Provider`s so tests
  can override them with `ProviderScope.overrides`.
- Navigation uses `context.go('/path')` — always go through the router, never
  `Navigator.push`.
- Decorative graphics (logo mark, grid background) are `CustomPainter`s, not
  asset files, so `pubspec.yaml` stays asset-free.

## Testing

```bash
flutter test
```

Widget tests live under `test/`. They wrap the app in
`MaterialApp.router(routerConfig: buildRouter())` inside a `ProviderScope`
with the auth repository overridden by a `mocktail` fake. Wrapping a page
directly in `MaterialApp(home: ...)` will throw
`No GoRouter found in context` as soon as navigation fires.

## Backend contract

The sign-in screen calls `POST /api/auth/login` with
`{"email": "...", "password": "..."}`. The sign-up screen calls
`POST /api/auth/signup` with
`{"name", "email", "password", "confirmPassword", "acceptTerms"}`. Both are
public mocks that always succeed and return:

```json
{
  "token": "mock-jwt-token",
  "user": { "id": "1", "email": "<echo>", "name": "<echo or default>" }
}
```

The Job Board reads from three protected endpoints (dev auth accepts any
or no bearer token; Firebase mode requires a real ID token):

- `GET /api/jobs?type=&experience=&location=&search=&page=&size=` →
  `{content:[JobDto], page, size, total}`. The client requests `size=100`
  so the full dataset fits one scroll column without pagination plumbing.
- `GET /api/stats` → `{activePosts, newApplicants, interviewsToday}`.
- `POST /api/assistant/message` `{message}` →
  `{reply, timestamp, source}` where `source ∈ canned|gemini|fallback`.

Errors follow the backend's shared envelope
(`{timestamp, status, error, message, path, fieldErrors}`); the client
surfaces `message` and, when present, per-field messages from `fieldErrors`
(e.g. `confirmPassword: "Passwords do not match"`).

## Status

- [x] Sign-in screen (design-matched)
- [x] Sign-up screen (etalente.co.za-matched; name/email/password/confirm + terms)
- [x] Mock login wired to `POST /api/auth/login`
- [x] Mock sign-up wired to `POST /api/auth/signup`
- [x] Routing + post-auth redirect to `/jobs`
- [x] Job Board — list from `/api/jobs`, filter pills (Experience / Contract),
      search box commits to the `search` query param, responsive sidebar +
      right-rail layout
- [x] Quick Stats card wired to `/api/stats`
- [x] Chatbot assistant sheet wired to `/api/assistant/message`
- [ ] Job details page
- [ ] Pagination / infinite scroll beyond the size=100 cap
- [ ] Firebase sign-in (Email/Password + Google) against real `/api/**`
