package com.enviro365.etalente.assistant.application;

import java.time.Instant;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import com.enviro365.etalente.assistant.config.AssistantProperties;
import com.enviro365.etalente.assistant.dto.AssistantMessageRequest;
import com.enviro365.etalente.assistant.dto.AssistantMessageResponse;

/**
 * Orchestrates assistant replies.
 *
 * <p>Picks an {@link AssistantProvider} based on
 * {@link AssistantProperties#provider()} and always keeps
 * {@link CannedAssistantProvider} as a guaranteed fallback. If the primary
 * provider throws — missing key, rate-limited, network outage, malformed
 * response — the service logs the failure and returns the canned reply so
 * the endpoint never surfaces a 5xx for provider-side issues.</p>
 */
@Service
public class AssistantService {

    private static final Logger log = LoggerFactory.getLogger(AssistantService.class);

    private final AssistantProperties properties;
    private final List<AssistantProvider> providers;
    private final CannedAssistantProvider canned;
    private final AssistantContextBuilder contextBuilder;

    public AssistantService(AssistantProperties properties,
                            List<AssistantProvider> providers,
                            CannedAssistantProvider canned,
                            AssistantContextBuilder contextBuilder) {
        this.properties = properties;
        this.providers = providers;
        this.canned = canned;
        this.contextBuilder = contextBuilder;
    }

    public AssistantMessageResponse reply(AssistantMessageRequest request) {
        AssistantProvider primary = selectPrimary();
        String context = contextBuilder.build();
        if (primary != canned) {
            try {
                ProviderReply providerReply = primary.reply(request.message(), context);
                return new AssistantMessageResponse(
                        providerReply.text(), Instant.now(), providerReply.source());
            } catch (RuntimeException ex) {
                log.warn("Assistant provider '{}' failed ({}); falling back to canned reply.",
                        primary.name(), ex.getMessage());
            }
        }
        ProviderReply fallback = canned.reply(request.message(), context);
        String source = (primary == canned) ? fallback.source() : "fallback";
        return new AssistantMessageResponse(fallback.text(), Instant.now(), source);
    }

    private AssistantProvider selectPrimary() {
        String configured = properties.provider();
        for (AssistantProvider p : providers) {
            if (p.name().equalsIgnoreCase(configured)) {
                return p;
            }
        }
        // Unknown provider name or its bean isn't active (e.g. gemini
        // conditional off) — fall back to canned.
        return canned;
    }
}
