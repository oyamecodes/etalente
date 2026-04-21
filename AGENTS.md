# AGENTS.md

Repo-specific notes for coding agents. General Spring/Flutter knowledge is assumed;
only non-obvious things live here. `README.md` and `backend/README.md` cover run/config
details — don't duplicate them here.

## Layout

- `backend/` — Spring Boot 3.5, Java 21, Maven Wrapper. The only thing that currently builds.
- `frontend/` — empty placeholder; Flutter app not yet scaffolded.
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
- Only `/api/**` is protected. `/actuator/health`, `/swagger-ui.html`, `/v3/api-docs/**` are public. Put new protected endpoints under `/api/**`.
- `FirebasePrincipal.signInProvider` is the Firebase `firebase.sign_in_provider` claim (`google.com`, `password`, `anonymous`, ...). It's extracted from nested token claims in `FirebaseAuthenticationFilter`, not directly exposed by `FirebaseToken`. Provider-gated endpoints (e.g. `POST /api/auth/google-signin`) read it off the principal — note that in `dev` mode the provider is `"dev"`, so such endpoints return 401 under dev auth. Tests override the principal via `spring-security-test`'s `authentication(...)` post-processor (see `AuthControllerTest`).
- Service-account secrets load from `FIREBASE_CREDENTIALS_JSON` (preferred) or `FIREBASE_CREDENTIALS_PATH`. Never commit either, and never hardcode them in tests.

## Assistant provider

- `POST /api/assistant/message` uses a pluggable `AssistantProvider`. Current impls: `canned` (default, also used by tests) and `gemini` (Google Generative Language API).
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

## Commit style

Conventional-ish prefixes (`feat`, `fix`, `chore`, `docs`, `test`, `refactor`). Never commit service-account JSON, `.env`, or Firebase keys.
