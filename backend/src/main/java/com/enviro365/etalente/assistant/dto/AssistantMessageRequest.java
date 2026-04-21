package com.enviro365.etalente.assistant.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Inbound assistant message. Body is bounded so the endpoint cannot be used
 * as a blind payload sink.
 */
public record AssistantMessageRequest(
        @NotBlank @Size(max = 2000) String message) {
}
