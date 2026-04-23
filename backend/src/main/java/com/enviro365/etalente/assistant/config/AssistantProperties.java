package com.enviro365.etalente.assistant.config;

import java.time.Duration;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Configuration for the assistant endpoint.
 *
 * @param provider         {@code canned} (default) or {@code gemini}. When
 *                         {@code gemini} is selected but {@code apiKey} is
 *                         blank, the service silently falls back to
 *                         {@code canned}.
 * @param apiKey           API key for the selected provider. Required for
 *                         {@code gemini}.
 * @param model            model name. Defaults to {@code gemini-2.5-flash-lite}.
 * @param baseUrl          provider base URL. Overridable for tests.
 * @param requestTimeout   HTTP read timeout for the provider call.
 * @param systemPrompt     short instruction prepended to every user
 *                         message so replies stay on-topic.
 */
@ConfigurationProperties(prefix = "assistant")
public record AssistantProperties(
        String provider,
        String apiKey,
        String model,
        String baseUrl,
        Duration requestTimeout,
        String systemPrompt) {

    public AssistantProperties {
        if (provider == null || provider.isBlank()) {
            provider = "canned";
        }
        if (model == null || model.isBlank()) {
            model = "gemini-2.5-flash-lite";
        }
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "https://generativelanguage.googleapis.com";
        }
        if (requestTimeout == null) {
            requestTimeout = Duration.ofSeconds(10);
        }
        if (systemPrompt == null || systemPrompt.isBlank()) {
            systemPrompt = """
                    You are the eTalente Assistant, a recruitment copilot embedded in the \
                    eTalente recruitment portal (https://etalente.co.za). Your ONLY purpose \
                    is to help users with eTalente-related tasks: navigating the portal, \
                    posting or managing jobs, understanding role details, reviewing \
                    applicants, scheduling interviews, interpreting dashboard stats, and \
                    answering questions about the sign-up / sign-in flow.

                    The portal has the following surfaces the user might be on:
                    - Sign-in ("/") and Sign-up ("/sign-up") screens.
                    - Job Board ("/jobs") with a sidebar (Dashboard, Job Posts, My Applications, \
                    Interviews, Messages), filter pills (All Filters, Skills, Experience, Contract), \
                    job cards (title, location, company, employment type, experience, salary range, \
                    posted by, closing date), a Quick Stats card (Active Posts, New Applicants, \
                    Interviews Today), a Featured Talent card, and this assistant.

                    Rules:
                    1. If the user asks about something unrelated to eTalente or recruitment \
                    (weather, general trivia, coding help, personal advice, other products), \
                    politely decline in one sentence and redirect them back to recruitment topics.
                    2. Never invent job listings, stats, or URLs. Only reference data explicitly \
                    provided to you in the CURRENT_SITE_CONTEXT block below.
                    3. Keep replies concise: at most 4 short sentences.
                    4. Use a warm, professional tone consistent with a recruitment portal.""";
        }
    }

    public boolean geminiConfigured() {
        return "gemini".equalsIgnoreCase(provider) && apiKey != null && !apiKey.isBlank();
    }
}
