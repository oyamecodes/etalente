package com.enviro365.etalente.assistant.application;

/**
 * Small value holder returned by an {@link AssistantProvider}. Carries both
 * the reply text and the identifier of the provider that produced it, so
 * the controller can surface which backend handled the request (useful for
 * demos where the LLM path may fall back to the canned provider).
 */
public record ProviderReply(String text, String source) {
}
