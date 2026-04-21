package com.enviro365.etalente.config;

import java.util.Collections;
import java.util.List;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Exposes a {@link CorsConfigurationSource} consumed by Spring Security.
 * Origins are configurable via {@code app.cors.allowed-origins}; wildcard
 * patterns (e.g. {@code http://localhost:*}) are used so Flutter dev runs on
 * any local port work out of the box.
 */
@Configuration
public class CorsConfig {

    private final CorsProperties properties;

    public CorsConfig(CorsProperties properties) {
        this.properties = properties;
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        List<String> origins = properties.allowedOrigins() == null
                ? Collections.emptyList()
                : properties.allowedOrigins();
        // allowedOriginPatterns (not allowedOrigins) is required for wildcard host/port matching.
        config.setAllowedOriginPatterns(origins);
        config.setAllowedMethods(List.of(
                HttpMethod.GET.name(),
                HttpMethod.POST.name(),
                HttpMethod.PUT.name(),
                HttpMethod.PATCH.name(),
                HttpMethod.DELETE.name(),
                HttpMethod.OPTIONS.name()));
        config.setAllowedHeaders(List.of("Authorization", "Content-Type", "Accept"));
        config.setExposedHeaders(List.of("Location"));
        config.setAllowCredentials(true);
        config.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
