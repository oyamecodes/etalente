package com.enviro365.etalente.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Firebase configuration bound from {@code firebase.*} properties.
 *
 * <p>Exactly one of {@link #credentialsJson()} or {@link #credentialsPath()}
 * should be populated when {@code app.auth.mode=firebase}. {@code credentialsJson}
 * takes precedence when both are set. When neither is set, the Firebase Admin
 * SDK falls back to Application Default Credentials
 * ({@code GOOGLE_APPLICATION_CREDENTIALS}).</p>
 */
@ConfigurationProperties(prefix = "firebase")
public record FirebaseProperties(
        String projectId,
        String credentialsJson,
        String credentialsPath) {
}
