package com.enviro365.etalente.config;

import java.io.ByteArrayInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;

/**
 * Initialises the Firebase Admin SDK when {@code app.auth.mode=firebase}.
 *
 * <p>Credentials are resolved in the following order:</p>
 * <ol>
 *   <li>{@code firebase.credentials-json} — raw service-account JSON (useful
 *       for CI / container environments).</li>
 *   <li>{@code firebase.credentials-path} — absolute path to a service-account
 *       JSON file.</li>
 *   <li>Application Default Credentials (the SDK picks up
 *       {@code GOOGLE_APPLICATION_CREDENTIALS}).</li>
 * </ol>
 *
 * <p>In {@code dev} mode this configuration is not active and no Firebase
 * network calls are made.</p>
 */
@Configuration
@ConditionalOnProperty(prefix = "app.auth", name = "mode", havingValue = "firebase")
public class FirebaseConfig {

    private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

    private final FirebaseProperties properties;

    public FirebaseConfig(FirebaseProperties properties) {
        this.properties = properties;
    }

    @Bean
    public FirebaseApp firebaseApp() throws IOException {
        if (!FirebaseApp.getApps().isEmpty()) {
            return FirebaseApp.getInstance();
        }

        FirebaseOptions.Builder builder = FirebaseOptions.builder()
                .setCredentials(loadCredentials());

        if (StringUtils.hasText(properties.projectId())) {
            builder.setProjectId(properties.projectId());
        }

        FirebaseApp app = FirebaseApp.initializeApp(builder.build());
        log.info("Firebase Admin SDK initialised (projectId={})", properties.projectId());
        return app;
    }

    @Bean
    public FirebaseAuth firebaseAuth(FirebaseApp firebaseApp) {
        return FirebaseAuth.getInstance(firebaseApp);
    }

    private GoogleCredentials loadCredentials() throws IOException {
        if (StringUtils.hasText(properties.credentialsJson())) {
            log.debug("Loading Firebase credentials from FIREBASE_CREDENTIALS_JSON");
            try (InputStream in = new ByteArrayInputStream(
                    properties.credentialsJson().getBytes(StandardCharsets.UTF_8))) {
                return GoogleCredentials.fromStream(in);
            }
        }
        if (StringUtils.hasText(properties.credentialsPath())) {
            log.debug("Loading Firebase credentials from {}", properties.credentialsPath());
            try (InputStream in = new FileInputStream(properties.credentialsPath())) {
                return GoogleCredentials.fromStream(in);
            }
        }
        log.debug("Falling back to Application Default Credentials");
        return GoogleCredentials.getApplicationDefault();
    }
}
