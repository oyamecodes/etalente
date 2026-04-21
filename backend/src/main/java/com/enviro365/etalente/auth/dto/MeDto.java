package com.enviro365.etalente.auth.dto;

/**
 * Caller identity projection returned by {@code GET /api/auth/me}. Mirrors
 * {@link com.enviro365.etalente.security.FirebasePrincipal} but is a
 * dedicated DTO so transport concerns stay out of the security layer.
 *
 * <p>{@code signInProvider} carries the Firebase {@code sign_in_provider}
 * claim (e.g. {@code "google.com"}, {@code "password"}). In
 * {@code app.auth.mode=dev} it is set to {@code "dev"}. May be {@code null}
 * if the claim was absent on the verified token.</p>
 */
public record MeDto(String uid, String email, String name, String signInProvider) {
}
