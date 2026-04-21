package com.enviro365.etalente.assistant.dto;

import java.time.Instant;

/**
 * Assistant reply envelope. {@code timestamp} is server-generated so
 * clients can render ordered chat bubbles without trusting local clocks.
 */
public record AssistantMessageResponse(String reply, Instant timestamp) {
}
