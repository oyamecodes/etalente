package com.enviro365.etalente.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/**
 * Binds {@code app.cors.*} properties.
 *
 * @param allowedOrigins origins permitted to call the API. Wildcard patterns
 *                       (e.g. {@code http://localhost:*}) are supported.
 */
@ConfigurationProperties(prefix = "app.cors")
public record CorsProperties(List<String> allowedOrigins) {
}
