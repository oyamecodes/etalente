package com.enviro365.etalente.assistant.dto;

import java.time.Instant;

/**
 * Assistant reply envelope.
 *
 * @param reply     generated or canned text for display to the user.
 * @param timestamp server-generated, so clients can render ordered chat
 *                  bubbles without trusting local clocks.
 * @param source    identifier of the provider that produced the reply
 *                  ({@code "gemini"}, {@code "canned"}, ...). Useful for the
 *                  UI to flag fallback responses and for debugging.
 */
public record AssistantMessageResponse(String reply, Instant timestamp, String source) {
}
