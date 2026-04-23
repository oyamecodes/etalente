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

## Status

- [x] Phase 1 — Scaffold
- [x] Phase 2 — Security (Firebase auth filter, dev bypass, Google sign-in verification)
- [x] Phase 3 — Features (jobs, stats, assistant, auth/me)
- [x] Phase 4 — Tests & documentation polish
- [x] Frontend — Flutter sign-in screen + job board placeholder
