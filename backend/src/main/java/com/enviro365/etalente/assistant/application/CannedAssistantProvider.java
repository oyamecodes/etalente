package com.enviro365.etalente.assistant.application;

import org.springframework.stereotype.Component;

/**
 * Fallback provider. Always available and always returns the same reply —
 * used when no LLM is configured, when the LLM call fails, or when running
 * tests. Ignores {@code systemContext}.
 */
@Component
public class CannedAssistantProvider implements AssistantProvider {

    public static final String SOURCE = "canned";

    private static final String CANNED_REPLY =
            "Hello! I'm your eTalente Assistant. How can I help you manage "
                    + "your recruitment workflow or find talent today?";

    @Override
    public String name() {
        return SOURCE;
    }

    @Override
    public ProviderReply reply(String userMessage, String systemContext) {
        return new ProviderReply(CANNED_REPLY, SOURCE);
    }
}
