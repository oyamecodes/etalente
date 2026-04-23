package com.enviro365.etalente.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Credentials body for {@code POST /api/auth/login}.
 *
 * <p>This endpoint is a deliberate mock per the eTalente assessment spec —
 * any syntactically valid email/password pair succeeds. See
 * {@link com.enviro365.etalente.auth.api.AuthController#login} for the
 * rationale for keeping it alongside the Firebase-verified endpoints.</p>
 */
public record LoginRequest(
        @NotBlank @Email String email,
        @NotBlank @Size(min = 6, max = 128) String password) {
}
