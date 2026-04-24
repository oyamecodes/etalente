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

### Sign in with Google

The OAuth handshake happens entirely on the client via `firebase_auth`'s
`GoogleAuthProvider` — the backend never sees Google's access token or
client secret. Flow:

1. Enable **Google** as a sign-in provider in Firebase console
   (`Build → Authentication → Sign-in method`).
2. In the Flutter app, call `FirebaseAuth.instance.signInWithProvider(GoogleAuthProvider())`
   (or the platform-specific equivalent). Firebase returns an ID token whose
   `firebase.sign_in_provider` claim is `google.com`.
3. Send that ID token as `Authorization: Bearer <token>` to any `/api/**`
   endpoint. `GET /api/auth/me` echoes the identity plus `signInProvider`;
   `POST /api/auth/google-signin` additionally asserts the provider is
   Google and rejects everything else with 401 — useful as a dedicated
   smoke test after wiring Google sign-in on the client.

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
| POST   | `/api/auth/login`          | no   | Mock email/password login per the spec. Body `{"email": "...", "password": "..."}` (both `@Valid`). Always succeeds with a static token and user `{id:"1", name:"Recruitment Admin"}` — intended for the Flutter client's sign-in screen without Firebase. |
| POST   | `/api/auth/signup`         | no   | Mock sign-up. Body `{"name", "email", "password", "confirmPassword", "acceptTerms"}`. Bean-Validation enforces non-blank name, valid email, 6–128 char password, `acceptTerms=true`; controller rejects `password != confirmPassword` with a `confirmPassword` field error. Returns the same envelope as `/login` but echoes the submitted `name` and `email` in `user`. No persistence — resubmitting an email is not a conflict. |
| GET    | `/api/auth/me`             | yes  | Echoes the verified Firebase principal (`uid`, `email`, `name`, `signInProvider`). |
| POST   | `/api/auth/google-signin`  | yes  | Confirms the ID token was minted via Google Sign-In. 200 with identity if `sign_in_provider=google.com`, 401 otherwise. Body is ignored — the provider check reads the Firebase token claim. |
| GET    | `/api/jobs`                | yes  | Filters: `type`, `experience`, `location`, `search` (matches title / company / location / description / skills). Paging: `page` (default `0`), `size` (default `20`, max `100`). Returns `{content, page, size, totalPages, total, hasMore}`. Each `content[]` entry carries `{id, title, company, location, type, experience, salaryRange, postedBy, closingDate}`. 400 on unknown `type` values. |
| GET    | `/api/jobs/{id}`           | yes  | Full job details. Adds `description` and `skills` on top of the list projection. 404 if unknown. |
| GET    | `/api/stats`               | yes  | Dashboard summary: `{activePosts, newApplicants, interviewsToday}`. |
| POST   | `/api/assistant/message`   | yes  | Body `{"message": "..."}` (non-blank, max 2000 chars). Returns `{reply, timestamp, source}`. `source` is `canned`, `gemini`, or `fallback` (see Assistant section below). |
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

# Identify the caller (dev mode returns the fake Dev Reviewer with signInProvider="dev")
curl http://localhost:8080/api/auth/me

# Confirm the caller signed in with Google (requires a real Firebase ID token
# minted via GoogleAuthProvider — dev mode returns 401 for this endpoint).
curl -X POST http://localhost:8080/api/auth/google-signin \
  -H 'Authorization: Bearer <google-firebase-id-token>'
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
| `assistant.provider`             | `ASSISTANT_PROVIDER`          | `canned`                                 | `canned` or `gemini`.                         |
| `assistant.api-key`              | `ASSISTANT_API_KEY`           | (empty)                                  | Required when `assistant.provider=gemini`.    |
| `assistant.model`                | `ASSISTANT_MODEL`             | `gemini-2.5-flash-lite`                  | Gemini model name.                            |
| `assistant.base-url`             | `ASSISTANT_BASE_URL`          | `https://generativelanguage.googleapis.com` | Override for tests / proxies.              |

## Assistant (chatbot)

`POST /api/assistant/message` supports two providers:

- **`canned`** (default) — returns a fixed reply. Used for tests and for
  reviewers who don't want to set up an API key.
- **`gemini`** — calls Google's Generative Language API
  (`gemini-2.5-flash-lite` by default). The API key is never logged and is
  passed via the `x-goog-api-key` header.

If the configured provider fails for any reason — missing key, HTTP
error, rate limit, malformed response, network timeout — the service
transparently falls back to the canned reply and tags the response with
`"source": "fallback"` so the client can surface the degraded state.

### Wiring Gemini

1. Visit <https://aistudio.google.com/apikey> and click **Create API key**.
   When prompted, choose **Create API key in new project** — newly-created
   AI Studio projects are automatically enrolled in the free tier
   (generous per-minute and per-day limits on `gemini-2.5-flash-lite`).
   Existing Google Cloud projects (including Firebase projects) are not
   enrolled and will return HTTP 429 with `limit: 0`.
2. Export the environment variables and restart the backend:

   ```bash
   export ASSISTANT_PROVIDER=gemini
   export ASSISTANT_API_KEY=AIza...
   ./mvnw spring-boot:run
   ```

3. Verify:

   ```bash
   curl -X POST http://localhost:8080/api/assistant/message \
     -H 'Content-Type: application/json' \
     -d '{"message":"Summarise the Senior Software Engineer role in one sentence."}'
   ```

   A live reply has `"source": "gemini"`. A `"source": "fallback"` means
   the call was attempted and failed — check the backend logs for the
   reason (look for `Assistant provider 'gemini' failed`).

## Testing

`./mvnw test` runs:

- `JobServiceTest` — filter, pagination, search, and not-found logic against
  the real in-memory repository.
- `JobControllerTest` — MVC slice (`@SpringBootTest` + `MockMvc`) covering
  list pagination, filters, details, 404, and invalid `type` handling.
- `AssistantServiceTest` — provider selection, exception fallback, and
  `source` propagation.
- `AssistantControllerTest` — canned reply happy path and `@Valid`-driven
  400s for blank/missing messages.
- `AuthControllerTest` — MVC slice covering `POST /api/auth/login` (happy
  path + validation errors on missing/invalid email/password),
  `POST /api/auth/signup` (happy path echoing submitted name/email,
  public-without-auth, per-field validation errors for blank name,
  invalid email, short password, mismatched confirmation, and
  unaccepted terms), `/api/auth/google-signin` (google-accepted,
  password-rejected, dev-rejected, missing-provider-rejected), and
  `/api/auth/me` (provider echoed, dev mode returns `"dev"`).
- `EtalenteApplicationTests` — context-loads smoke.

All tests run under `app.auth.mode=dev` and `assistant.provider=canned`,
so no external credentials are required to execute the suite.

## Assumptions & trade-offs

1. **Mock login/signup alongside real Firebase auth.** The spec asked for a mock
   `POST /api/auth/login`; we provide it (public endpoint, static token) so
   the Flutter sign-in screen works without any Firebase project.
   `POST /api/auth/signup` follows the same mock pattern so the sign-up
   screen can be built and demoed end-to-end against the same backend.
   For the rest of `/api/**` we use Firebase ID-token verification plus
   `GET /api/auth/me`, which is more representative of a real integration.
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
   `{content, page, size, totalPages, total, hasMore}` — `totalPages`
   and `hasMore` are derived server-side so clients don't have to
   reimplement the maths. Client-side filtering is still fine;
   server-side filters are additionally provided.
7. **Assistant is provider-pluggable** with a canned fallback. The
   default `canned` provider keeps reviewers productive without any API
   keys; `gemini` wires in a real LLM. Swapping to another provider
   (OpenAI, Groq, Ollama, etc.) is a single class implementing
   `AssistantProvider`.

## What I'd improve with more time

- **Persistent storage** — swap the in-memory `JobRepository` for JPA +
  Flyway migrations against Postgres. The repository interface was
  carved out for exactly this.
- **Real sign-up flow** — `POST /api/auth/signup` is a mock echo; wire
  it to Firebase Authentication and persist the resulting user.
- **Assistant streaming** — `/api/assistant/message` is synchronous;
  SSE / WebSocket streaming would make the Gemini provider feel live.
  Upgrade the assistant to a real tool-using agent with memory.
- **Contract tests** — Spring Cloud Contract stubs shared with the
  Flutter client, so both sides of the API envelope stay in lock-step.
- **Rate limiting & audit logging** on authenticated endpoints
  (Bucket4j for rate limits; a structured audit appender for the log).
- **CI** — GitHub Actions pipeline running `./mvnw verify`,
  `flutter analyze`, and `flutter test` on each PR, plus Docker image
  publishing on tagged releases.
