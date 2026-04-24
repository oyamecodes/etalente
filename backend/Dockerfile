# syntax=docker/dockerfile:1.7
# -----------------------------------------------------------------------------
# Stage 1 — build the Spring Boot fat jar with the Maven Wrapper.
# Using the Eclipse Temurin 21 JDK image lets us match the `java.version`
# declared in pom.xml without depending on whatever JDK the host happens
# to have installed.
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace

# Copy only the wrapper + pom first so the dependency layer can cache
# across source-only changes.
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q -DskipTests dependency:go-offline

COPY src/ src/
RUN --mount=type=cache,target=/root/.m2 ./mvnw -q -DskipTests package \
    && cp target/*.jar /workspace/app.jar

# -----------------------------------------------------------------------------
# Stage 2 — minimal JRE runtime. `jre-alpine` keeps the final image small
# while still providing the glibc-compatible shim musl-java needs.
# -----------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine AS runtime
RUN apk add --no-cache curl tini \
    && addgroup -S app && adduser -S app -G app
WORKDIR /app
COPY --from=build --chown=app:app /workspace/app.jar ./app.jar

USER app
EXPOSE 8080

# Compose wires the actuator healthcheck; this one is a defensive default
# so `docker run` picks up failures too.
HEALTHCHECK --interval=10s --timeout=3s --start-period=30s --retries=5 \
  CMD curl -fsS http://localhost:8080/actuator/health || exit 1

# tini reaps zombies and forwards signals cleanly to the JVM.
ENTRYPOINT ["/sbin/tini", "--", "java", "-jar", "/app/app.jar"]
