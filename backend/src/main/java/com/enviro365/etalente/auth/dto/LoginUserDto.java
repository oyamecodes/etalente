package com.enviro365.etalente.auth.dto;

/**
 * Authenticated user projection returned inside {@link LoginResponse}.
 * Shape matches the eTalente assessment spec.
 */
public record LoginUserDto(String id, String email, String name) {
}
