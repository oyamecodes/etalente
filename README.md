# eTalente

Simplified recruitment portal built for the **Enviro365 Flutter Technical
Assessment**.

- Spring Boot 3 REST API (Java 21) — `backend/`
- Flutter web/mobile app (sign-in, sign-up, Job Board, Job Details,
  chatbot assistant) — `frontend/`

The repo ships with Dockerfiles and a `docker-compose.yml` so you can
run the whole thing with **one command** — no JDK, Maven, or Flutter
SDK installed on your machine.

---

## Quickstart (one command)

**Prerequisites:** [Docker Desktop](https://docs.docker.com/desktop/) —
that's it.

```bash
git clone https://github.com/oyamecodes/etalente.git
cd etalente
docker compose up --build
```

First build takes ~3–5 minutes (Flutter web SDK + Maven dependencies).
Subsequent runs start in seconds thanks to layer caching.

Then open **<http://localhost:8080>** in your browser.

To stop the stack:

```bash
docker compose down
```

### Logging in

The sign-in screen accepts **any** email/password — it's a mock endpoint
per the assessment spec. After login you land on the Job Board.

If you want to try the real Firebase auth path, see
[`backend/README.md`](backend/README.md#running-against-a-real-firebase-project).

---

## What you'll see

| Path | Screen | Notes |
|------|--------|-------|
| `/` | Sign-in | Mock endpoint; always succeeds. |
| `/sign-up` | Sign-up | Matches the live etalente.co.za design. |
| `/jobs` | Job Board | 28 seed jobs, filter pills, search, pager. |
| `/jobs/:id` | Job Details | Full description + required skills. |

Other niceties on the Job Board:

- **Chatbot assistant** (yellow button, bottom right) — quick-reply
  chips, responsive popup (bottom-right on desktop, fullscreen on
  mobile).
- **Quick Stats** right-rail card — live counts from `/api/stats`.
- **Session-aware routing** — deep-linking to `/jobs` while signed-out
  redirects to `/`; signing in while on `/` redirects to `/jobs`.

The backend API is also reachable directly:

- Swagger UI: <http://localhost:8081/swagger-ui.html>
- Health: <http://localhost:8081/actuator/health>
- Jobs: <http://localhost:8081/api/jobs?size=5>

---

## Repository layout

```
.
├── backend/              Spring Boot 3 API (Java 21, Maven)
│   └── README.md         → API setup, endpoints, config
├── frontend/             Flutter app (Riverpod + go_router)
│   └── README.md         → Flutter setup, architecture, tests
├── docker-compose.yml    Two-service stack (frontend + backend)
├── Tiltfile              Optional dev loop (local processes, no Docker)
├── AGENTS.md             Contributor / AI-agent guidance
└── README.md             (this file)
```

---

## Running without Docker

If you'd rather hack on the code directly, each service has its own
dev loop documented in its README:

- **Backend**: [`backend/README.md`](backend/README.md) — `./mvnw spring-boot:run`
- **Frontend**: [`frontend/README.md`](frontend/README.md) — `flutter run -d chrome`

Or use [Tilt](https://tilt.dev) to run both as supervised host
processes (no containers):

```bash
tilt up -- --frontend   # backend + Flutter, unified dashboard
```

Details in [`AGENTS.md`](AGENTS.md#local-orchestration-tilt).

---

## Configuration

Defaults (`APP_AUTH_MODE=dev`, canned assistant replies) are set so
the stack runs with **zero configuration**. To override, drop a `.env`
next to `docker-compose.yml`:

```env
# Enable real Firebase ID-token verification
APP_AUTH_MODE=firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CREDENTIALS_JSON={"type":"service_account",...}   # single line

# Swap the assistant for Google's Gemini
ASSISTANT_PROVIDER=gemini
ASSISTANT_API_KEY=your-api-key

# Change exposed host ports
FRONTEND_PORT=8080
BACKEND_PORT=8081
```

`.env` is gitignored — **never** commit service-account JSON.

Full reference: [`backend/README.md`](backend/README.md#configuration-reference).

---

## Architecture at a glance

- **Stateless backend.** No database — jobs live in an in-memory
  repository behind a domain interface so a real store can swap in
  without touching callers. Read-through caching on hot paths.
- **Firebase auth with a dev bypass.** `APP_AUTH_MODE=dev` injects a
  fake principal so reviewers can run the API without a Firebase
  project; `APP_AUTH_MODE=firebase` verifies ID tokens with the
  Firebase Admin SDK.
- **Feature-first packages** on both sides (`auth/`, `jobs/`,
  `stats/`, `assistant/`), each split into
  `api / application / domain / infrastructure`.
- **Docker deploy**: two containers on a private network. The frontend
  nginx reverse-proxies `/api` to the backend, so the browser only
  ever talks to one origin — no CORS dance.

Deep dives live in the service READMEs.

---

## Testing

```bash
# Backend unit/integration tests (49 tests)
cd backend && ./mvnw test

# Flutter widget tests (30 tests)
cd frontend && flutter test
```

Both suites run with zero external dependencies (dev auth + canned
assistant, no Firebase project or API keys required).

---

## Documentation map

- **[`backend/README.md`](backend/README.md)** — API endpoints,
  Firebase setup, caching, assistant providers, assumptions &
  trade-offs, what I'd improve.
- **[`frontend/README.md`](frontend/README.md)** — Flutter
  architecture, routing, state management, widget test patterns, what
  I'd improve.
- **[`AGENTS.md`](AGENTS.md)** — repo-specific conventions for
  contributors and AI coding agents.
- **`Enviro365 - Flutter Technical Assessment.pdf`** — the original
  spec this project implements.
