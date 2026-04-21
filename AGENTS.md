# AGENTS.md

Guidance for humans and coding agents working in this repository.

## Repository layout

```
/
├── backend/     Spring Boot 3 REST API (Java 21, Maven Wrapper)
├── frontend/    Flutter 3+ app (added in a later phase)
├── README.md
└── AGENTS.md
```

Each sub-project owns its own `README.md` with run instructions and any
conventions specific to that stack.

## Backend conventions

- **Package root**: `com.enviro365.etalente`.
- **Feature-first packaging**: `auth/`, `jobs/`, `stats/`, `assistant/`. Inside
  each feature, prefer an `api / application / domain / infrastructure`
  split over flat `controller/service/repository` packages.
- **DTOs** live in `<feature>/dto/` and are separate from domain models.
- **Security** is stateless. `app.auth.mode` selects between `firebase`
  (real ID-token verification) and `dev` (fake principal for reviewers/tests).
- **No database.** Data is hardcoded in `seed/` and served through an
  in-memory repository that implements a domain interface. Do not add JPA
  or a real DB without updating this document first.
- **No committed secrets.** Firebase service account JSON is loaded from
  env vars (`FIREBASE_CREDENTIALS_JSON` or `FIREBASE_CREDENTIALS_PATH`).

### Commands (run from `backend/`)

```
./mvnw clean compile       # compile
./mvnw spring-boot:run     # run the API on :8080
./mvnw test                # unit + slice tests
./mvnw verify              # full build with tests
./mvnw -q -DskipTests package
```

Tests are written against `app.auth.mode=dev` so they never need Firebase.

## Frontend conventions

TBD — will be documented when the Flutter app lands.

## Commit style

- Conventional-ish prefixes: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`.
- One commit per development phase during initial scaffolding; finer grained
  afterwards.
- Never commit secrets, service account JSON, or `.env` files.

## Trade-offs & deviations from the spec

The spec allows a fully mocked backend. Deliberate deviations:

1. `POST /api/auth/login` is replaced by Firebase ID-token verification plus
   `GET /api/auth/me`. Rationale: a mock login demonstrates nothing about
   real auth integration, and Firebase was requested for this project.
2. `app.auth.mode=dev` exists solely for reviewer convenience and local
   tests. It is not a production posture.
3. `/api/jobs` supports pagination via `page`/`size` query params and returns
   a `{content, page, size, total}` envelope. The spec allows client-side
   filtering; server-side filters are additionally provided.
