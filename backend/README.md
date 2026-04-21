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

## Endpoints (planned)

| Method | Path                       | Auth | Notes                                           |
|--------|----------------------------|------|-------------------------------------------------|
| GET    | `/api/auth/me`             | yes  | Returns the authenticated user profile.         |
| GET    | `/api/jobs`                | yes  | Supports `type`, `experience`, `location`, `search`, `page`, `size`. |
| GET    | `/api/jobs/{id}`           | yes  | Job details.                                    |
| GET    | `/api/stats`               | yes  | Dashboard stats.                                |
| POST   | `/api/assistant/message`   | yes  | Canned assistant reply.                         |
| GET    | `/actuator/health`         | no   | Liveness probe.                                 |
| GET    | `/swagger-ui.html`         | no   | API documentation.                              |

Endpoints are implemented in later phases; this README describes the target shape.

## Configuration reference

| Property                         | Env var                       | Default                                  | Notes                                         |
|----------------------------------|-------------------------------|------------------------------------------|-----------------------------------------------|
| `app.auth.mode`                  | `APP_AUTH_MODE`               | `dev`                                    | `firebase` or `dev`.                          |
| `app.cors.allowed-origins`       | `APP_CORS_ALLOWED_ORIGINS`    | `http://localhost:*,http://127.0.0.1:*`  | Comma-separated origins.                      |
| `firebase.project-id`            | `FIREBASE_PROJECT_ID`         | (empty)                                  | Required when `app.auth.mode=firebase`.       |
| `firebase.credentials-json`      | `FIREBASE_CREDENTIALS_JSON`   | (empty)                                  | Raw service-account JSON. Takes precedence.   |
| `firebase.credentials-path`      | `FIREBASE_CREDENTIALS_PATH`   | (empty)                                  | Absolute path to service-account JSON file.   |

## Assumptions & trade-offs

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
