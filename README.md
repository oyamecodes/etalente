# eTalente

Simplified recruitment portal built for the Enviro365 Flutter Technical Assessment.

Monorepo containing:

- **`backend/`** — Spring Boot 3 REST API (Java 21, Maven).
- **`frontend/`** — Flutter 3+ application (sign-in screen + job board placeholder).

## Architecture at a glance

- **Auth**: Two paths coexist.
  - `POST /api/auth/login` — public mock login (email + password) used by
    the Flutter sign-in screen. Always succeeds; returns a static token
    and user. Keeps reviewers productive without a Firebase project.
  - Firebase ID-token verification for the rest of `/api/**`. The Flutter
    app (post-integration) signs the user in with Firebase and attaches
    the ID token as `Authorization: Bearer <token>`; the backend verifies
    it with the Firebase Admin SDK. `POST /api/auth/google-signin`
    additionally asserts the token was minted via Google.
- **Backend**: stateless REST API. Data is in-memory (no database required per
  the spec) behind a repository interface so it can be swapped for JPA later.
- **Frontend**: Flutter, Riverpod for state, `go_router` for routing,
  feature-first package layout mirroring the backend.

## Repository layout

```
.
├── backend/     Spring Boot API
├── frontend/    Flutter app (placeholder)
├── AGENTS.md    Contributor / agent guidance
└── README.md    (this file)
```

## Getting started

See [`backend/README.md`](backend/README.md) for API setup, environment
variables, and Firebase configuration, and [`frontend/README.md`](frontend/README.md)
for the Flutter app.

## Running with Tilt

[Tilt](https://tilt.dev) supervises the backend and (optionally) the Flutter
frontend as host-side processes — no Docker, no Kubernetes. One command, one
dashboard, unified logs.

Prerequisites:

- JDK 21 and the bundled `./mvnw` (already in `backend/`).
- Flutter SDK on `PATH` (only needed when running with `--frontend`).
- Tilt: `curl -fsSL https://raw.githubusercontent.com/tilt-dev/tilt/master/scripts/install.sh | bash`

```bash
tilt up                                        # backend only
tilt up -- --frontend                          # backend + Flutter on emulator-5554
tilt up -- --frontend --flutter-device=chrome  # backend + Flutter on Chrome
```

The Tilt UI (<http://localhost:10350>) exposes a manual **`backend-tests`**
resource — click its refresh icon to run `./mvnw test` on demand. Backend env
vars (`ASSISTANT_API_KEY`, `APP_AUTH_MODE`, `FIREBASE_*`) are inherited from
the shell that ran `tilt up`.

## Running with Docker

Multi-stage Dockerfiles in `backend/` and `frontend/` plus a root
`docker-compose.yml` bring the whole stack up with one command — no
local JDK, Maven, or Flutter SDK needed beyond Docker itself.

```bash
docker compose up --build       # SPA on http://localhost:8080
docker compose down
```

Topology:

- **frontend** — multi-stage build (`flutter build web` → `nginx:alpine`)
  serving the compiled bundle on port 80 (mapped to host `:8080` by
  default; override with `FRONTEND_PORT`).
- **backend** — multi-stage build (Maven → `eclipse-temurin:21-jre-alpine`)
  running the Spring Boot fat jar on port 8080 (mapped to host `:8081`
  for direct `curl` / Swagger access; override with `BACKEND_PORT`).
- The frontend nginx reverse-proxies `/api`, `/actuator`, `/v3/api-docs`,
  and `/swagger-ui` to the backend over the private `etalente` network,
  so the browser only ever talks to one origin. **No CORS dance.** The
  SPA is built with `API_BASE_URL=""` so it uses relative URLs — the
  same image works unchanged in any deploy environment.
- Compose gates `frontend` on the backend's `/actuator/health` so the
  SPA never comes up against a cold API.

Defaults: `APP_AUTH_MODE=dev`, `ASSISTANT_PROVIDER=canned` — the stack
runs with zero configuration. Override via shell env or an `.env` file
next to `docker-compose.yml`:

```bash
APP_AUTH_MODE=firebase \
FIREBASE_PROJECT_ID=your-project \
FIREBASE_CREDENTIALS_JSON="$(cat serviceAccount.json)" \
ASSISTANT_PROVIDER=gemini ASSISTANT_API_KEY=... \
docker compose up --build
```

To ship the frontend image standalone against a remote API (skipping
the nginx proxy), bake the absolute URL at build time:

```bash
docker build -t etalente-frontend \
  --build-arg API_BASE_URL=https://api.example.com ./frontend
```

## Assumptions & trade-offs

Captured in detail in `backend/README.md`. Highlights:

- Kept the spec's mock `POST /api/auth/login` as a public endpoint for
  the Flutter sign-in screen, while also adding real Firebase ID-token
  verification and a `GET /api/auth/me` endpoint for the rest of
  `/api/**`. The mock login keeps reviewers unblocked; Firebase auth
  demonstrates real integration for the protected endpoints.
- A `app.auth.mode=dev` profile bypasses Firebase so reviewers can run the API
  without provisioning a Firebase project. Production-like runs use
  `app.auth.mode=firebase`.
- Feature-first package layout (`jobs/`, `stats/`, `assistant/`, `auth/`) with
  internal `api / application / domain / infrastructure` separation.
- Read-through caching (`@EnableCaching` + in-memory
  `ConcurrentMapCacheManager`) on `JobService.list` / `findById` and
  `StatsService.current()` so repeated dashboard loads don't re-walk
  the mock repository. Swap in Caffeine/Redis for production.

## Status

- [x] Phase 1 — Scaffold
- [x] Phase 2 — Security (Firebase auth filter, dev bypass, Google sign-in verification)
- [x] Phase 3 — Features (jobs, stats, assistant, auth/me)
- [x] Phase 4 — Tests & documentation polish
- [x] Frontend — sign-in, sign-up, Job Board, Job Details, Chatbot assistant

## What I'd improve with more time

- **Persistent storage**: swap the in-memory `JobRepository` for JPA +
  Flyway (the interface was already carved out for this).
- **Secure token storage on the client**: the sign-in token currently
  lives in memory only; `flutter_secure_storage` would survive app
  restarts.
- **Real sign-up flow**: `POST /api/auth/signup` is a mock echo — wire
  it to Firebase Authentication and persist the resulting user.
- **Pagination UI**: currently a simple page-based pager
  (Prev / Page X of Y / Next, default `size=10`). Swapping to infinite
  scroll with a `ScrollController` + `hasMore` tail is straightforward
  — the envelope already carries `totalPages` and `hasMore`.
- **Assistant streaming**: `/api/assistant/message` is synchronous; SSE
  / WebSocket streaming would make the Gemini provider feel live.
- **Accessibility pass**: colour-contrast audit on the navy/yellow
  palette, keyboard navigation for the filter pills and assistant
  popup, semantic labels on icon-only buttons.
- **End-to-end tests**: a Patrol or `integration_test` suite driving
  sign-in → job board → details → assistant would complement the
  current widget tests.
- **Dark mode**: the palette is currently pinned to the supplied mocks
  via hard-coded `AppColors` tokens, so a proper dark theme means
  redefining every token per-brightness and routing widgets through a
  `ThemeExtension`. Left out to avoid regressing mock fidelity.
