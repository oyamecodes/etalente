package com.enviro365.etalente.config;

import java.io.IOException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

import com.enviro365.etalente.common.error.ApiError;
import com.enviro365.etalente.security.DevAuthenticationFilter;
import com.enviro365.etalente.security.FirebaseAuthenticationFilter;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.firebase.auth.FirebaseAuth;

import jakarta.servlet.http.HttpServletResponse;

/**
 * Stateless security chain.
 *
 * <ul>
 *   <li>{@code /api/**} requires an authenticated principal.</li>
 *   <li>Swagger UI, OpenAPI docs, actuator health, and preflight OPTIONS are public.</li>
 *   <li>In {@code firebase} mode a {@link FirebaseAuthenticationFilter} verifies ID tokens.</li>
 *   <li>In {@code dev} mode a {@link DevAuthenticationFilter} injects a fake principal.</li>
 * </ul>
 */
@Configuration
@EnableConfigurationProperties({AuthProperties.class, CorsProperties.class, FirebaseProperties.class})
public class SecurityConfig {

    private static final Logger log = LoggerFactory.getLogger(SecurityConfig.class);

    private final AuthProperties authProperties;
    private final ObjectMapper objectMapper;

    public SecurityConfig(AuthProperties authProperties, ObjectMapper objectMapper) {
        this.authProperties = authProperties;
        this.objectMapper = objectMapper;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http,
                                                   @Qualifier("corsConfigurationSource") CorsConfigurationSource corsSource,
                                                   ObjectProvider<FirebaseAuth> firebaseAuthProvider)
            throws Exception {

        http
                .cors(cors -> cors.configurationSource(corsSource))
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(sm -> sm.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(
                                "/actuator/health",
                                "/v3/api-docs/**",
                                "/swagger-ui.html",
                                "/swagger-ui/**").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/api/**").authenticated()
                        .anyRequest().denyAll())
                .exceptionHandling(ex -> ex
                        .authenticationEntryPoint(authenticationEntryPoint())
                        .accessDeniedHandler(accessDeniedHandler()))
                .httpBasic(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable);

        if (authProperties.isDevMode()) {
            log.warn("Starting with app.auth.mode=dev — every request is authenticated as '{}'. "
                    + "Do NOT run this mode in production.", authProperties.devUser().uid());
            http.addFilterBefore(
                    new DevAuthenticationFilter(authProperties.devUser()),
                    UsernamePasswordAuthenticationFilter.class);
        } else {
            FirebaseAuth firebaseAuth = firebaseAuthProvider.getIfAvailable();
            if (firebaseAuth == null) {
                throw new IllegalStateException(
                        "app.auth.mode=firebase but no FirebaseAuth bean is available. "
                                + "Check FIREBASE_CREDENTIALS_JSON/FIREBASE_CREDENTIALS_PATH and FIREBASE_PROJECT_ID.");
            }
            http.addFilterBefore(
                    new FirebaseAuthenticationFilter(firebaseAuth),
                    UsernamePasswordAuthenticationFilter.class);
        }

        return http.build();
    }

    private AuthenticationEntryPoint authenticationEntryPoint() {
        return (request, response, authException) ->
                writeError(response, HttpStatus.UNAUTHORIZED, "Authentication required", request.getRequestURI());
    }

    private AccessDeniedHandler accessDeniedHandler() {
        return (request, response, accessDeniedException) ->
                writeError(response, HttpStatus.FORBIDDEN, "Access denied", request.getRequestURI());
    }

    private void writeError(HttpServletResponse response, HttpStatus status, String message, String path)
            throws IOException {
        ApiError body = ApiError.of(status.value(), status.getReasonPhrase(), message, path);
        response.setStatus(status.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        objectMapper.writeValue(response.getOutputStream(), body);
    }
}
