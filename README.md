# eTalente

Simplified recruitment portal built for the Enviro365 Flutter Technical Assessment.

Monorepo containing:

- **`backend/`** — Spring Boot 3 REST API (Java 21, Maven).
- **`frontend/`** — Flutter 3+ application (added in a later phase).

## Architecture at a glance

- **Auth**: Firebase Authentication (Email/Password). The Flutter app signs the
  user in with Firebase and attaches the resulting ID token as
  `Authorization: Bearer <token>` on every API call. The backend verifies the
  token with the Firebase Admin SDK.
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
- [ ] Phase 2 — Security (Firebase auth filter, dev bypass)
- [ ] Phase 3 — Features (jobs, stats, assistant, auth/me)
- [ ] Phase 4 — Tests & documentation polish
- [ ] Frontend — Flutter app
