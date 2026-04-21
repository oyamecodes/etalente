package com.enviro365.etalente.auth.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.auth.dto.MeDto;
import com.enviro365.etalente.security.FirebasePrincipal;
import com.enviro365.etalente.security.SecurityUtils;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Replaces the spec's {@code POST /api/auth/login}: auth happens against
 * Firebase directly from the client, and the backend only exposes an
 * endpoint to echo back the verified identity. See {@code AGENTS.md} for
 * the rationale behind this deviation.
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "Caller identity derived from the Firebase ID token")
@SecurityRequirement(name = "bearer-jwt")
public class AuthController {

    @GetMapping("/me")
    @Operation(summary = "Return the authenticated caller's identity")
    public MeDto me() {
        FirebasePrincipal principal = SecurityUtils.requirePrincipal();
        return new MeDto(principal.uid(), principal.email(), principal.name());
    }
}
