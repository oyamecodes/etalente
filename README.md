# eTalente

Simplified recruitment portal built for the Enviro365 Flutter Technical Assessment.

Monorepo containing:

- **`backend/`** — Spring Boot 3 REST API (Java 21, Maven).
- **`frontend/`** — Flutter 3+ application (added in a later phase).

## Architecture at a glance

- **Auth**: Firebase Authentication (Email/Password and Google). The Flutter
  app signs the user in with Firebase and attaches the resulting ID token as
  `Authorization: Bearer <token>` on every API call. The backend verifies the
  token with the Firebase Admin SDK and additionally exposes
  `POST /api/auth/google-signin` to assert a token was minted by Google.
- **Backend**: stateless REST API. Data is in-memory (no database required per
  the spec) behind a repository interface so it can be swapped for JPA later.
- **Frontend**: Flutter, state management and architecture TBD in a later
  phase.

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
variables, and Firebase configuration. Frontend instructions will live in
`frontend/README.md` once that phase begins.

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

- Replaced the spec's mock `POST /api/auth/login` with real Firebase ID-token
  verification and a `GET /api/auth/me` endpoint. This is more representative
  of a real integration and costs little extra.
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
- [ ] Frontend — Flutter app
