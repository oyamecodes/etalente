# AGENTS.md

Repo-specific notes for coding agents. General Spring/Flutter knowledge is assumed;
only non-obvious things live here. `README.md` and `backend/README.md` cover run/config
details — don't duplicate them here.

## Layout

- `backend/` — Spring Boot 3.5, Java 21, Maven Wrapper.
- `frontend/` — Flutter app (sign-in, sign-up, Job Board dashboard). Riverpod + `go_router`, feature-first layout mirroring the backend.
- Root `Enviro365 - Flutter Technical Assessment.pdf` is the spec. Deviations are listed at the bottom of `backend/README.md`.

## Backend architecture (not obvious from filenames)

- Package root: `com.enviro365.etalente`.
- Feature-first: `auth/`, `jobs/`, `stats/`, `assistant/`. Each feature internally splits into `api / application / domain / infrastructure` (+ `dto/`). Add new features the same way — do **not** fall back to flat `controller/service/repository`.
- Cross-cutting lives outside features: `config/` (Spring `@Configuration` + `@ConfigurationProperties`), `security/` (auth filters + principal), `common/error` (global `@RestControllerAdvice` + error envelope), `common/web`, `seed/MockJobData` (hardcoded job list).
- **No database, no JPA.** Jobs are served from an in-memory repository implementing a domain interface. Don't introduce Spring Data / Flyway / a DB without updating this file and `backend/README.md`.
- **Lombok** is on the compile-time annotation processor path (see `pom.xml` — required or builds break). It is excluded from the Spring Boot fat jar.

## Security model

- Stateless. Two auth filters gated by `app.auth.mode`:
  - `firebase` → `FirebaseAuthenticationFilter` verifies `Authorization: Bearer <id-token>` via Firebase Admin SDK.
  - `dev` (default) → `DevAuthenticationFilter` injects a static `FirebasePrincipal` (`dev-user` / `dev@etalente.local`, `signInProvider="dev"`). Required for tests and reviewers without a Firebase project.
- Only `/api/**` is protected. `/actuator/health`, `/swagger-ui.html`, `/v3/api-docs/**` are public. `POST /api/auth/login` and `POST /api/auth/signup` are also explicitly permitted (public mocks per the spec — always succeed, return a static token and user). Put new protected endpoints under `/api/**`.
- `FirebasePrincipal.signInProvider` is the Firebase `firebase.sign_in_provider` claim (`google.com`, `password`, `anonymous`, ...). It's extracted from nested token claims in `FirebaseAuthenticationFilter`, not directly exposed by `FirebaseToken`. Provider-gated endpoints (e.g. `POST /api/auth/google-signin`) read it off the principal — note that in `dev` mode the provider is `"dev"`, so such endpoints return 401 under dev auth. Tests override the principal via `spring-security-test`'s `authentication(...)` post-processor (see `AuthControllerTest`).
- Service-account secrets load from `FIREBASE_CREDENTIALS_JSON` (preferred) or `FIREBASE_CREDENTIALS_PATH`. Never commit either, and never hardcode them in tests.

## Assistant provider

- `POST /api/assistant/message` uses a pluggable `AssistantProvider`. Current impls: `canned` (default, also used by tests) and `gemini` (Google Generative Language API).
- On every call, `AssistantService` asks `AssistantContextBuilder` to produce the system instruction: `AssistantProperties.systemPrompt` (scope + refusal rules) plus a `CURRENT_SITE_CONTEXT` block built live from `StatsService.current()` and the first N (`MAX_JOBS_IN_CONTEXT = 8`) entries of `JobRepository.findAll()`. `AssistantProvider.reply(userMessage, systemContext)` receives that string; `GeminiAssistantProvider` uses it as `system_instruction`, `CannedAssistantProvider` ignores it. Context-builder failures are swallowed (prompt still builds with `… unavailable` placeholders) so reviewers without Gemini never see a 500.
- **Any** exception from a non-canned provider is swallowed and the response is tagged `"source": "fallback"`. When debugging assistant failures, look at backend logs for `Assistant provider '<name>' failed` — the HTTP response alone won't tell you it failed.
- Adding a provider = one class implementing `AssistantProvider` + wiring in `config/`. Keep the canned fallback behavior.

## Commands (run from `backend/`)

```
./mvnw spring-boot:run                      # dev-mode API on :8080
./mvnw test                                 # full suite (dev auth, canned assistant)
./mvnw test -Dtest=JobServiceTest           # single class
./mvnw test -Dtest=JobServiceTest#filtersByType   # single method
./mvnw verify                               # build + tests
./mvnw -q -DskipTests package               # jar without tests
```

Tests force `app.auth.mode=dev` and `assistant.provider=canned`; they need no env vars or network.

## Local orchestration (Tilt)

Root `Tiltfile` runs backend (and optionally Flutter) as `local_resource`s — no Docker, no Kubernetes, so WSL Docker Desktop integration is **not** required. `tilt up -- --frontend` gates the frontend resource so the Tiltfile stays valid before `frontend/` is scaffolded. Flutter device defaults to `emulator-5554`; override with `--flutter-device=<id>`. A `backend-tests` resource is `TRIGGER_MODE_MANUAL` + `auto_init=False` — click to run `./mvnw test`. Backend env vars (`ASSISTANT_API_KEY`, `APP_AUTH_MODE`, `FIREBASE_*`) are inherited from the shell.

## Error envelope

All errors use the same JSON shape emitted by `common/error` advice:
`{timestamp, status, error, message, path, fieldErrors}`. `fieldErrors` is only populated for `@Valid` failures. New exceptions should route through this advice rather than returning ad-hoc bodies.

## Pagination contract

`/api/jobs` returns `{content, page, size, total}` with `size` capped at 100. Preserve this envelope — the Flutter client will depend on it.

## Frontend architecture (not obvious from filenames)

- Feature-first under `lib/`: `app/` (theme, router, `App` widget), `core/api/` (`ApiClient` + typed `ApiException`), `features/<feature>/{data,domain,application,presentation/widgets}`, `shared/widgets/`. Mirror this layout for new features — do **not** collapse into a flat `screens/` + `services/` tree.
- State: **Riverpod** (`flutter_riverpod`). Controllers are `AsyncNotifier`s in `application/`; repositories in `data/` are plain classes exposed via `Provider`s and overridden in tests with `ProviderScope.overrides`. Routing: **`go_router`** built in `app/router.dart` — navigate with `context.go('/path')`, not `Navigator.push`.
- API base URL is resolved at build time via `--dart-define=API_BASE_URL=...`. Defaults: `http://10.0.2.2:8080` on Android (emulator → host loopback), `http://localhost:8080` elsewhere. Override for physical devices / deployed backends.
- Sign-in talks to `POST /api/auth/login` (public mock). The returned token is held in memory only (no secure storage yet) — see `AuthController`. Post-login navigation goes to `/jobs` (placeholder page).
- Sign-up (`/sign-up`) talks to `POST /api/auth/signup` (public mock; always succeeds, echoes name/email). Visual design intentionally differs from sign-in — it matches the live [etalente.co.za/sign-up](https://etalente.co.za/sign-up) site (outlined floating-label fields, Talent/Employer segmented toggle, dark-navy CTA) rather than the PDF mock used for sign-in. The UI collects `name/email/password/confirmPassword`; `acceptTerms` is sent `true` implicitly by clicking Create Account (mirrors the live site). Extra fields present on the live site screenshot (disability, contact number, alt number, username) are intentionally omitted.
- **Job Board** (`/jobs`) is the post-auth landing page and matches `job board.jpeg` at the repo root. The layout is owned by `shared/widgets/dashboard_shell.dart` — adaptive three-region shell (`AppSideNav` + body + right rail), with breakpoints at 1100 (wide), 700 (medium, right-rail stacks below) and narrower (hamburger Drawer, single-column). `JobBoardPage` watches `jobBoardControllerProvider` (fetches `GET /api/jobs?size=100`), `FilterPills` mutates a `StateProvider<JobBoardFilters>` which re-triggers the controller via `ref.watch`. Right rail: `QuickStatsCard` hits `/api/stats`; `ChatbotAssistantCard` + chat FAB share `openAssistantSheet()` which drives `AssistantController` against `/api/assistant/message`; `FeaturedTalentCard` is intentionally static (no backend endpoint). Sidebar nav items other than Job Posts are wired to a "coming soon" snackbar; Logout clears the in-memory session and routes to `/`.
- **Job Details** (`/jobs/:id`) — tapping a `JobCard` calls `context.go('/jobs/${job.id}')`. `JobDetailsPage` reuses `DashboardShell` and watches `jobDetailProvider` (a `FutureProvider.family.autoDispose<JobDetail, String>` over `JobRepository.findById` → `GET /api/jobs/{id}`). Renders title, meta chips, experience/salary/closing-date stats, "Required Skills" chips and "About the Role" from `JobDetail.description`/`.skills`. Apply CTA is a "coming soon" stub.
- **eTalente Assistant popup** matches `job board 2.jpeg`. `openAssistantSheet()` is adaptive: viewport ≥700px wide → `showGeneralDialog` anchored bottom-right (max 380×560, yellow header with robot avatar + green online dot, quick-reply chips, rounded input, "Help Center" footer); narrower → fullscreen `Dialog`. Quick-reply chips ("Post New Job", "Review Applicants") only show while the transcript has no user message and, when tapped, send the label as a user message via `AssistantController.send()`. The chat FAB watches `assistantOpenProvider` (`StateProvider<bool>` flipped by the launcher) and hides while the popup is mounted.
- Widget tests covering `/jobs` must override `jobRepositoryProvider`, `statsRepositoryProvider` *and* `assistantRepositoryProvider` — the shared fakes live in `test/test_helpers/fake_dashboard_repos.dart`. `buildRouter({initialLocation: '/jobs'})` lets tests land directly on the board without running through sign-in.
- Logo mark, background grid, and decorative graphics are `CustomPainter`s, not SVG/raster assets — keeps `pubspec.yaml` asset-free.
- Widget tests wrap the app in `MaterialApp.router(routerConfig: buildRouter())` inside a `ProviderScope` with the repo overridden. Wrapping a page in `MaterialApp(home: ...)` will blow up as soon as the page calls `context.go(...)` ("No GoRouter found in context").
- Commands (run from `frontend/`): `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run -d chrome`, `flutter run -d <android-device-id>`.

## Commit style

Conventional-ish prefixes (`feat`, `fix`, `chore`, `docs`, `test`, `refactor`). Never commit service-account JSON, `.env`, or Firebase keys.
