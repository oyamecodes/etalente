package com.enviro365.etalente.assistant.application;

import java.time.Duration;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import com.enviro365.etalente.assistant.config.AssistantProperties;

/**
 * Calls Google's Gemini REST API
 * ({@code generativelanguage.googleapis.com}) and extracts the reply text.
 *
 * <p>Only instantiated when {@code assistant.provider=gemini}; a missing
 * or blank API key will cause the first call to throw and let the service
 * layer fall back to the canned provider.</p>
 *
 * <p>The API key is passed via the {@code x-goog-api-key} header rather
 * than a query string so it never lands in access logs.</p>
 */
@Component
@ConditionalOnProperty(prefix = "assistant", name = "provider", havingValue = "gemini")
public class GeminiAssistantProvider implements AssistantProvider {

    public static final String SOURCE = "gemini";

    private static final Logger log = LoggerFactory.getLogger(GeminiAssistantProvider.class);

    private final AssistantProperties properties;
    private final RestClient restClient;

    public GeminiAssistantProvider(AssistantProperties properties) {
        this.properties = properties;
        this.restClient = buildRestClient(properties.baseUrl(), properties.requestTimeout());
    }

    @Override
    public String name() {
        return SOURCE;
    }

    @Override
    public ProviderReply reply(String userMessage, String systemContext) {
        if (properties.apiKey() == null || properties.apiKey().isBlank()) {
            throw new IllegalStateException("ASSISTANT_API_KEY is not configured");
        }

        // Prefer the resolved context (static scope + live site state).
        // Fall back to the static prompt if the caller passed nothing so
        // the provider still refuses to run without any guardrails.
        String systemInstruction = (systemContext == null || systemContext.isBlank())
                ? properties.systemPrompt()
                : systemContext;

        Map<String, Object> payload = Map.of(
                "system_instruction", Map.of(
                        "parts", List.of(Map.of("text", systemInstruction))),
                "contents", List.of(Map.of(
                        "role", "user",
                        "parts", List.of(Map.of("text", userMessage)))),
                "generationConfig", Map.of(
                        "temperature", 0.4,
                        "maxOutputTokens", 256));

        String path = "/v1beta/models/" + properties.model() + ":generateContent";

        @SuppressWarnings("unchecked")
        Map<String, Object> response = restClient.post()
                .uri(path)
                .header("x-goog-api-key", properties.apiKey())
                .contentType(MediaType.APPLICATION_JSON)
                .body(payload)
                .retrieve()
                .body(Map.class);

        String text = extractText(response);
        if (text == null || text.isBlank()) {
            throw new IllegalStateException("Gemini returned an empty response");
        }
        return new ProviderReply(text.trim(), SOURCE);
    }

    @SuppressWarnings("unchecked")
    private static String extractText(Map<String, Object> response) {
        if (response == null) {
            return null;
        }
        List<Map<String, Object>> candidates = (List<Map<String, Object>>) response.get("candidates");
        if (candidates == null || candidates.isEmpty()) {
            log.warn("Gemini response contained no candidates: {}", response);
            return null;
        }
        Map<String, Object> content = (Map<String, Object>) candidates.get(0).get("content");
        if (content == null) {
            return null;
        }
        List<Map<String, Object>> parts = (List<Map<String, Object>>) content.get("parts");
        if (parts == null || parts.isEmpty()) {
            return null;
        }
        Object text = parts.get(0).get("text");
        return text == null ? null : text.toString();
    }

    private static RestClient buildRestClient(String baseUrl, Duration timeout) {
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout((int) timeout.toMillis());
        factory.setReadTimeout((int) timeout.toMillis());
        return RestClient.builder()
                .baseUrl(baseUrl)
                .requestFactory(factory)
                .build();
    }
}
