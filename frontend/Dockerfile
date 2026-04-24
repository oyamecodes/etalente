# syntax=docker/dockerfile:1.7
# -----------------------------------------------------------------------------
# Stage 1 — build the Flutter web bundle.
#
# We intentionally pin the Flutter tag to match the `environment.sdk`
# declared in pubspec.yaml. cirruslabs/flutter is the de-facto image for
# CI; it ships Dart + Flutter + the web toolchain.
#
# API_BASE_URL is left empty on purpose: the SPA uses relative URLs so
# nginx in stage 2 can reverse-proxy /api and /actuator to the backend.
# Override at build time with `--build-arg API_BASE_URL=https://api.example.com`
# if you want to deploy the static bundle against a remote API instead.
# -----------------------------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:3.41.7 AS build
WORKDIR /app
ARG API_BASE_URL=""

# The official image runs as root; git marks /app as "unsafe" when the
# owning uid differs from the one that cloned, which breaks
# `flutter pub get`. Trust the workdir upfront.
RUN git config --global --add safe.directory /app

# Resolve packages before copying the rest so dependency layers cache.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the project and build for web. CanvasKit is the
# default renderer and keeps parity with `flutter run -d chrome`.
COPY . .
RUN flutter pub get \
    && flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL}"

# -----------------------------------------------------------------------------
# Stage 2 — nginx:alpine serving the static bundle + proxying /api.
# -----------------------------------------------------------------------------
FROM nginx:1.27-alpine AS runtime
RUN apk add --no-cache curl
COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -fsS http://localhost/ > /dev/null || exit 1

CMD ["nginx", "-g", "daemon off;"]
