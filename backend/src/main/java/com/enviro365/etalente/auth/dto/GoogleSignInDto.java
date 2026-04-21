package com.enviro365.etalente.auth.dto;

/**
 * Response for {@code POST /api/auth/google-signin}. Echoes the verified
 * identity and surfaces the sign-in provider so the Flutter client can
 * confirm that the Firebase ID token it sent really was minted by Google
 * Sign-In (as opposed to e.g. email/password).
 *
 * @param uid           Firebase UID.
 * @param email         verified email address (Google always provides one).
 * @param name          display name from the Google profile.
 * @param signInProvider Firebase sign-in provider — always {@code "google.com"}
 *                      for successful responses on this endpoint.
 */
public record GoogleSignInDto(String uid, String email, String name, String signInProvider) {
}
