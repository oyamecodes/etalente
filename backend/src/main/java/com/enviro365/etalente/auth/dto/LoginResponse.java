package com.enviro365.etalente.auth.dto;

/**
 * Response body for {@code POST /api/auth/login}. Shape mirrors the
 * eTalente assessment spec ({@code token} + {@code user{id,email,name}}).
 */
public record LoginResponse(String token, LoginUserDto user) {
}
