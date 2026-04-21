package com.enviro365.etalente.assistant.application;

import org.springframework.stereotype.Component;

/**
 * Fallback provider. Always available and always returns the same reply —
 * used when no LLM is configured, when the LLM call fails, or when running
 * tests.
 */
@Component
public class CannedAssistantProvider implements AssistantProvider {

    public static final String SOURCE = "canned";

    private static final String CANNED_REPLY =
            "Thanks for your message! I'm the eTalente assistant. "
                    + "I can help you explore open roles, summarise job details, "
                    + "and answer questions about the hiring process.";

    @Override
    public String name() {
        return SOURCE;
    }

    @Override
    public ProviderReply reply(String userMessage) {
        return new ProviderReply(CANNED_REPLY, SOURCE);
    }
}
