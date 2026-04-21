package com.enviro365.etalente.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;

/**
 * Configures Swagger UI with a bearer-token auth scheme so the "Authorize"
 * dialog lets callers paste a Firebase ID token and try protected endpoints
 * from the browser.
 */
@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME = "bearer-jwt";

    @Bean
    public OpenAPI etalenteOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("eTalente API")
                        .version("v1")
                        .description("Mocked recruitment portal API backing the eTalente Flutter client."))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME))
                .components(new Components().addSecuritySchemes(SECURITY_SCHEME,
                        new SecurityScheme()
                                .name(SECURITY_SCHEME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Firebase ID token. In dev mode the backend ignores this header.")));
    }
}
