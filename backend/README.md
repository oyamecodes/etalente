# eTalente Backend

Spring Boot 3 REST API for the eTalente recruitment portal.

- **Java**: 21
- **Build**: Maven (via the included `./mvnw` wrapper)
- **Auth**: Firebase Authentication (ID-token verification); `dev` mode available for reviewers.
- **Data**: in-memory mock data — no database required.

## Quick start (dev mode, no Firebase required)

```bash
cd backend
./mvnw spring-boot:run
```

The API starts on <http://localhost:8080>. With the default profile
(`app.auth.mode=dev`), every request is authenticated as a fake "Dev Reviewer"
principal, so you can hit endpoints without an ID token.

Swagger UI: <http://localhost:8080/swagger-ui.html>

## Running against a real Firebase project

1. Create a Firebase project and enable **Email/Password** sign-in
   (`Build → Authentication → Sign-in method`).
2. Generate a service account key:
   `Project settings → Service accounts → Generate new private key`.
   Save the JSON **outside this repository**.
3. Export the environment variables and launch:

   ```bash
   export APP_AUTH_MODE=firebase
   export FIREBASE_PROJECT_ID=your-project-id
   export FIREBASE_CREDENTIALS_PATH=/absolute/path/to/service-account.json
   # or, alternatively:
   # export FIREBASE_CREDENTIALS_JSON='{"type":"service_account", ...}'
   ./mvnw spring-boot:run
   ```

The backend expects every `/api/**` request to carry
`Authorization: Bearer <firebase-id-token>`. The Flutter client obtains the
token from `firebase_auth` after the user signs in.

## Useful commands

```bash
./mvnw clean compile       # compile
./mvnw spring-boot:run     # run the API
./mvnw test                # unit + slice tests (runs in dev auth mode)
./mvnw verify              # full build including tests
./mvnw -q -DskipTests package
```

## Endpoints

| Method | Path                       | Auth | Notes                                           |
|--------|----------------------------|------|-------------------------------------------------|
| GET    | `/api/auth/me`             | yes  | Echoes the verified Firebase principal (`uid`, `email`, `name`). |
| GET    | `/api/jobs`                | yes  | Filters: `type`, `experience`, `location`, `search`. Paging: `page` (default `0`), `size` (default `20`, max `100`). Returns `{content, page, size, total}`. |
| GET    | `/api/jobs/{id}`           | yes  | Full job details including `description` and `skills`. 404 if unknown. |
| GET    | `/api/stats`               | yes  | Dashboard summary: `{activePosts, newApplicants, interviewsToday}`. |
| POST   | `/api/assistant/message`   | yes  | Body `{"message": "..."}` (non-blank, max 2000 chars). Returns `{reply, timestamp}` with a canned reply. |
| GET    | `/actuator/health`         | no   | Liveness probe.                                 |
| GET    | `/swagger-ui.html`         | no   | Interactive API docs (OpenAPI 3).               |

### Example requests (dev mode)

```bash
# List the first 5 Full-time jobs in Cape Town
curl 'http://localhost:8080/api/jobs?type=Full-time&location=Cape&size=5'

# Fetch a single job
curl http://localhost:8080/api/jobs/job-1

# Dashboard stats
curl http://localhost:8080/api/stats

# Send an assistant message
curl -X POST http://localhost:8080/api/assistant/message \
  -H 'Content-Type: application/json' \
  -d '{"message":"Tell me about open Flutter roles"}'

# Identify the caller (dev mode returns the fake Dev Reviewer)
curl http://localhost:8080/api/auth/me
```

In `firebase` mode every request above must additionally carry
`Authorization: Bearer <firebase-id-token>`.

### Error shape

All errors are returned as JSON using a single consistent envelope:

```json
{
  "timestamp": "2026-04-21T04:24:15Z",
  "status": 404,
  "error": "Not Found",
  "message": "Job not found: abc",
  "path": "/api/jobs/abc",
  "fieldErrors": null
}
```

Validation failures (e.g. `POST /api/assistant/message` with a blank
message) populate `fieldErrors` with `{field, message}` entries.

## Configuration reference

| Property                         | Env var                       | Default                                  | Notes                                         |
|----------------------------------|-------------------------------|------------------------------------------|-----------------------------------------------|
| `app.auth.mode`                  | `APP_AUTH_MODE`               | `dev`                                    | `firebase` or `dev`.                          |
| `app.cors.allowed-origins`       | `APP_CORS_ALLOWED_ORIGINS`    | `http://localhost:*,http://127.0.0.1:*`  | Comma-separated origins.                      |
| `firebase.project-id`            | `FIREBASE_PROJECT_ID`         | (empty)                                  | Required when `app.auth.mode=firebase`.       |
| `firebase.credentials-json`      | `FIREBASE_CREDENTIALS_JSON`   | (empty)                                  | Raw service-account JSON. Takes precedence.   |
| `firebase.credentials-path`      | `FIREBASE_CREDENTIALS_PATH`   | (empty)                                  | Absolute path to service-account JSON file.   |

## Testing

`./mvnw test` runs:

- `JobServiceTest` — filter, pagination, search, and not-found logic against
  the real in-memory repository.
- `JobControllerTest` — MVC slice (`@SpringBootTest` + `MockMvc`) covering
  list pagination, filters, details, 404, and invalid `type` handling.
- `AssistantControllerTest` — canned reply happy path and `@Valid`-driven
  400s for blank/missing messages.
- `EtalenteApplicationTests` — context-loads smoke.

All tests run under `app.auth.mode=dev`, so no Firebase credentials are
required to execute the suite.



1. **Real Firebase auth over mock login.** The spec allowed a mock
   `POST /api/auth/login`. Replaced with Firebase ID-token verification plus
   `GET /api/auth/me`. A mock login demonstrates nothing about real auth
   integration and the spec explicitly asked for Firebase.
2. **`app.auth.mode=dev` is a reviewer convenience**, not a production mode.
   It injects a static principal so the API can be exercised without a
   Firebase project. Tests also run in this mode.
3. **No database.** Jobs live in an in-memory list behind a repository
   interface, so swapping in JPA later is a small change.
4. **Feature-first packages** (`jobs/`, `stats/`, `assistant/`, `auth/`)
   each with `api / application / domain / infrastructure` subpackages,
   rather than a flat `controller/service/repository` layout.
5. **Firebase Admin SDK** is used directly rather than Spring Security's
   generic OAuth2 resource server. Less configuration, canonical for
   Firebase, but couples the backend to Firebase (acceptable — that is
   the explicit choice for this project).
6. **Pagination envelope** on `/api/jobs` returns
   `{content, page, size, total}`. Client-side filtering is still fine;
   server-side filters are additionally provided.
7. **Assistant** returns a single canned reply for now. Keyword routing
   or actual LLM integration is a trivial swap inside `AssistantService`.

## What I'd improve with more time

- Persist jobs and applications in Postgres with Flyway migrations.
- Expand the assistant to a real tool-using agent.
- Contract tests (Spring Cloud Contract) shared with the Flutter client.
- Rate limiting and audit logging on authenticated endpoints.
- Docker Compose + GitHub Actions CI.
