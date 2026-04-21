package com.enviro365.etalente.security;

/**
 * Identity derived from a verified Firebase ID token (or synthesised by the
 * dev-mode filter). Keeps only the fields the application actually needs —
 * the raw token claims are intentionally not exposed further than this layer.
 *
 * @param uid             Firebase UID, stable across sessions.
 * @param email           verified email address, may be {@code null} for providers that
 *                        do not expose one (e.g. anonymous sign-in).
 * @param name            display name, may be {@code null}.
 * @param signInProvider  Firebase {@code firebase.sign_in_provider} claim — e.g.
 *                        {@code "google.com"}, {@code "password"}, {@code "anonymous"}.
 *                        In {@code app.auth.mode=dev} this is set to {@code "dev"}.
 *                        May be {@code null} if the claim is absent.
 */
public record FirebasePrincipal(String uid, String email, String name, String signInProvider) {
}
