# Tiltfile — local dev orchestration for eTalente (backend + Flutter frontend).
#
# Uses `local_resource` only — no Docker, no Kubernetes. Both processes run
# on the host so Spring Boot DevTools hot-reload and Flutter hot-reload
# work natively. See README.md § "Running with Tilt" for prerequisites.
#
# Usage:
#   tilt up                                   # backend only
#   tilt up -- --frontend                     # backend + Flutter
#   tilt up -- --frontend --flutter-device=chrome
#
# The `backend-tests` resource is manual: click the refresh icon in the
# Tilt UI to run `./mvnw test` on demand.

config.define_bool("frontend")
config.define_string("flutter-device")
cfg = config.parse()

run_frontend = cfg.get("frontend", False)
flutter_device = cfg.get("flutter-device", "emulator-5554")

# ---------------------------------------------------------------------------
# Backend — Spring Boot on :8080
# ---------------------------------------------------------------------------
# Environment variables (ASSISTANT_API_KEY, APP_AUTH_MODE, FIREBASE_*, etc.)
# are inherited from the shell that ran `tilt up`, which is what you want.
local_resource(
    name = "backend",
    serve_cmd = "./mvnw -q spring-boot:run",
    serve_dir = "backend",
    readiness_probe = probe(
        period_secs = 5,
        http_get = http_get_action(port = 8080, path = "/actuator/health"),
    ),
    deps = [
        "backend/src",
        "backend/pom.xml",
    ],
    ignore = [
        "backend/target",
        "backend/**/*.log",
    ],
    labels = ["api"],
    links = [
        link("http://localhost:8080/swagger-ui.html", "Swagger UI"),
        link("http://localhost:8080/actuator/health", "Health"),
    ],
)

# One-click test run. TRIGGER_MODE_MANUAL keeps it from running on file
# changes — click the refresh icon in the Tilt UI to invoke it.
local_resource(
    name = "backend-tests",
    cmd = "./mvnw -q test",
    dir = "backend",
    trigger_mode = TRIGGER_MODE_MANUAL,
    auto_init = False,
    labels = ["checks"],
)

# ---------------------------------------------------------------------------
# Frontend — Flutter (optional; enable with `tilt up -- --frontend`)
# ---------------------------------------------------------------------------
# Defined now behind a flag so the Tiltfile remains valid before the Flutter
# app is scaffolded. Once `frontend/pubspec.yaml` exists, flip the flag on.
if run_frontend:
    local_resource(
        name = "frontend",
        serve_cmd = "flutter run -d {}".format(flutter_device),
        serve_dir = "frontend",
        deps = [
            "frontend/lib",
            "frontend/pubspec.yaml",
        ],
        ignore = [
            "frontend/build",
            "frontend/.dart_tool",
        ],
        resource_deps = ["backend"],
        labels = ["app"],
    )
