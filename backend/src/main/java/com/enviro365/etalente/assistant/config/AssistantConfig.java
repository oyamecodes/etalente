package com.enviro365.etalente.assistant.config;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Registers {@link AssistantProperties} so {@code assistant.*} keys in
 * {@code application.yml} / environment variables are bound into a typed
 * record.
 */
@Configuration
@EnableConfigurationProperties(AssistantProperties.class)
public class AssistantConfig {
}
