package com.enviro365.etalente.auth.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

/**
 * Registration body for {@code POST /api/auth/signup}.
 *
 * <p>Like {@link LoginRequest}, this endpoint is a deliberate mock per the
 * eTalente assessment spec — any syntactically valid payload succeeds and
 * returns a canned {@code mock-jwt-token}. The field shape mirrors the
 * sign-up form on the real eTalente portal so the Flutter client can be
 * pointed at a real backend later without reshaping the request.</p>
 *
 * <p>{@code confirmPassword} / {@code password} equality is enforced in
 * {@link com.enviro365.etalente.auth.api.AuthController#signUp} because
 * cross-field validation yields a clearer {@code fieldErrors} entry than
 * a class-level {@code @AssertTrue} would.</p>
 */
public record SignUpRequest(
        @NotBlank @Size(max = 120) String name,
        @NotBlank @Email @Size(max = 254) String email,
        @NotBlank @Size(min = 6, max = 128) String password,
        @NotBlank @Size(min = 6, max = 128) String confirmPassword,
        @AssertTrue(message = "Terms and conditions must be accepted") boolean acceptTerms) {
}
