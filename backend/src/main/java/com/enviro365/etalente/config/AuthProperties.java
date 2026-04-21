package com.enviro365.etalente.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Binds {@code app.auth.*} properties.
 *
 * @param mode    either {@code firebase} (real ID-token verification) or
 *                {@code dev} (fake principal injected by the filter chain).
 * @param devUser principal used when {@code mode == dev}.
 */
@ConfigurationProperties(prefix = "app.auth")
public record AuthProperties(String mode, DevUser devUser) {

    public boolean isDevMode() {
        return "dev".equalsIgnoreCase(mode);
    }

    public record DevUser(String uid, String email, String name) {
    }
}
