package com.enviro365.etalente.auth.dto;

/**
 * Caller identity projection returned by {@code GET /api/auth/me}. Mirrors
 * {@link com.enviro365.etalente.security.FirebasePrincipal} but is a
 * dedicated DTO so transport concerns stay out of the security layer.
 */
public record MeDto(String uid, String email, String name) {
}
