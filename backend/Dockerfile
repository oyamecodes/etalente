# Multi-stage build for the etalente backend.
#
# Stage 1 runs the Maven build against a Temurin JDK 21 image and
# produces the Spring Boot fat jar. Stage 2 copies just the jar into a
# slim JRE image so the runtime surface is minimal.
#
# Build:   docker build -t etalente-backend ./backend
# Run:     docker run --rm -p 8080:8080 etalente-backend
# Env:     APP_AUTH_MODE=dev (default), ASSISTANT_PROVIDER=canned (default),
#          ASSISTANT_API_KEY, FIREBASE_CREDENTIALS_JSON — see backend/README.md

FROM eclipse-temurin:21-jdk-alpine AS build
WORKDIR /workspace

# Copy Maven wrapper + pom first so `dependency:go-offline` is cached
# across source-only rebuilds.
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN chmod +x mvnw && ./mvnw -q -DskipTests dependency:go-offline

COPY src src
RUN ./mvnw -q -DskipTests package \
    && cp target/*.jar app.jar

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Non-root runtime user.
RUN addgroup -S etalente && adduser -S -G etalente etalente
USER etalente

COPY --from=build /workspace/app.jar /app/app.jar

EXPOSE 8080

# Reasonable container-aware JVM defaults.
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75"
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
