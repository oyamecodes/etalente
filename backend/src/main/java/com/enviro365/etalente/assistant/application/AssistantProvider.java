package com.enviro365.etalente.assistant.application;

/**
 * Strategy for producing an assistant reply. Keeps {@link AssistantService}
 * agnostic of whether the text came from a real LLM, a local stub, or a
 * canned fallback.
 *
 * <p>Implementations should throw any exception on failure; the service
 * layer is responsible for choosing a fallback.</p>
 */
public interface AssistantProvider {

    /** Short identifier used in {@link ProviderReply#source()}. */
    String name();

    /** Produce a reply for the given user message. */
    ProviderReply reply(String userMessage);
}
