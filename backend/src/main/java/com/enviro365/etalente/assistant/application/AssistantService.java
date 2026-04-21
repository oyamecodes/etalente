package com.enviro365.etalente.assistant.application;

import java.time.Instant;

import org.springframework.stereotype.Service;

import com.enviro365.etalente.assistant.dto.AssistantMessageRequest;
import com.enviro365.etalente.assistant.dto.AssistantMessageResponse;

/**
 * Stub assistant. Returns a canned reply regardless of input — the brief
 * explicitly permits this, and wiring a real LLM is out of scope for the
 * assessment. The service boundary exists so a real provider (OpenAI,
 * Vertex, etc.) can be dropped in later without touching the controller.
 */
@Service
public class AssistantService {

    private static final String CANNED_REPLY =
            "Thanks for your message! I'm the eTalente assistant. "
                    + "I can help you explore open roles, summarise job details, "
                    + "and answer questions about the hiring process.";

    public AssistantMessageResponse reply(AssistantMessageRequest request) {
        // The request is validated upstream; we intentionally ignore its
        // contents for now and always return the same reply.
        return new AssistantMessageResponse(CANNED_REPLY, Instant.now());
    }
}
