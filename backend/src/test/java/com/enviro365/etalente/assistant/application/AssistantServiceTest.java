package com.enviro365.etalente.assistant.application;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.enviro365.etalente.assistant.config.AssistantProperties;
import com.enviro365.etalente.assistant.dto.AssistantMessageRequest;
import com.enviro365.etalente.assistant.dto.AssistantMessageResponse;

/**
 * Unit tests for the assistant orchestration logic. We wire the service by
 * hand with stub providers instead of using Spring so provider selection,
 * exception handling, and {@code source} propagation are verified in
 * isolation from the web layer and the Gemini HTTP client.
 */
class AssistantServiceTest {

    private static final AssistantMessageRequest MESSAGE =
            new AssistantMessageRequest("hello");

    /** Stub context builder — the orchestration logic doesn't care about the
     *  actual context string, only that it's threaded through to providers. */
    private static final AssistantContextBuilder CONTEXT = new AssistantContextBuilder(null, null, null) {
        @Override public String build() { return "TEST_CONTEXT"; }
    };

    @Test
    void returnsCannedReplyWhenProviderIsCanned() {
        CannedAssistantProvider canned = new CannedAssistantProvider();
        AssistantService service = new AssistantService(
                properties("canned", null), List.of(canned), canned, CONTEXT);

        AssistantMessageResponse response = service.reply(MESSAGE);

        assertThat(response.source()).isEqualTo("canned");
        assertThat(response.reply()).isNotBlank();
        assertThat(response.timestamp()).isNotNull();
    }

    @Test
    void returnsPrimaryReplyWhenPrimarySucceeds() {
        CannedAssistantProvider canned = new CannedAssistantProvider();
        AssistantProvider stub = new StubProvider("gemini", "Live LLM answer.");
        AssistantService service = new AssistantService(
                properties("gemini", "key"), List.of(stub, canned), canned, CONTEXT);

        AssistantMessageResponse response = service.reply(MESSAGE);

        assertThat(response.source()).isEqualTo("gemini");
        assertThat(response.reply()).isEqualTo("Live LLM answer.");
    }

    @Test
    void fallsBackToCannedWhenPrimaryThrows() {
        CannedAssistantProvider canned = new CannedAssistantProvider();
        AssistantProvider broken = new AssistantProvider() {
            @Override public String name() { return "gemini"; }
            @Override public ProviderReply reply(String userMessage, String systemContext) {
                throw new IllegalStateException("boom");
            }
        };
        AssistantService service = new AssistantService(
                properties("gemini", "key"), List.of(broken, canned), canned, CONTEXT);

        AssistantMessageResponse response = service.reply(MESSAGE);

        // Non-canned primary failed → source is tagged as 'fallback' so the
        // client can distinguish from a reviewer running without a key.
        assertThat(response.source()).isEqualTo("fallback");
        assertThat(response.reply()).isNotBlank();
    }

    @Test
    void unknownProviderNameFallsBackToCanned() {
        CannedAssistantProvider canned = new CannedAssistantProvider();
        AssistantService service = new AssistantService(
                properties("nonsense", null), List.of(canned), canned, CONTEXT);

        AssistantMessageResponse response = service.reply(MESSAGE);

        // When the configured name doesn't resolve to any registered
        // provider we treat it the same as 'canned' — reviewers get a
        // clean response rather than a stack trace.
        assertThat(response.source()).isEqualTo("canned");
    }

    // ---------------------------------------------------------------------

    private static AssistantProperties properties(String provider, String apiKey) {
        return new AssistantProperties(
                provider, apiKey, null, null, Duration.ofSeconds(5), null);
    }

    private record StubProvider(String name, String text) implements AssistantProvider {
        @Override
        public ProviderReply reply(String userMessage, String systemContext) {
            return new ProviderReply(text, name);
        }
    }
}
