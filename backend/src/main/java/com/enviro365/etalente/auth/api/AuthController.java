package com.enviro365.etalente.auth.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.auth.dto.GoogleSignInDto;
import com.enviro365.etalente.auth.dto.MeDto;
import com.enviro365.etalente.common.error.ApiError;
import com.enviro365.etalente.security.FirebasePrincipal;
import com.enviro365.etalente.security.SecurityUtils;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;

/**
 * Replaces the spec's {@code POST /api/auth/login}: auth happens against
 * Firebase directly from the client, and the backend only exposes
 * verification endpoints. See {@code AGENTS.md} for the rationale behind
 * this deviation.
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "Caller identity derived from the Firebase ID token")
@SecurityRequirement(name = "bearer-jwt")
public class AuthController {

    static final String GOOGLE_PROVIDER = "google.com";

    @GetMapping("/me")
    @Operation(summary = "Return the authenticated caller's identity")
    public MeDto me() {
        FirebasePrincipal principal = SecurityUtils.requirePrincipal();
        return new MeDto(
                principal.uid(),
                principal.email(),
                principal.name(),
                principal.signInProvider());
    }

    /**
     * Confirms the caller's Firebase ID token was minted via Google Sign-In.
     *
     * <p>The OAuth handshake lives entirely in the Flutter client via
     * {@code firebase_auth}'s {@code GoogleAuthProvider}. By the time we get
     * here, the security filter has already verified the ID token. This
     * endpoint only asserts the {@code sign_in_provider} claim is
     * {@code "google.com"} — tokens from other providers (password,
     * anonymous, apple.com, ...) are rejected with 401 so mis-wired
     * clients fail loudly rather than silently succeeding.</p>
     */
    @PostMapping("/google-signin")
    @Operation(summary = "Verify the caller signed in with Google via Firebase Auth")
    @ApiResponse(responseCode = "200", description = "Token was minted by Google Sign-In")
    @ApiResponse(responseCode = "401", description = "Token came from a different Firebase provider")
    public ResponseEntity<?> googleSignIn(HttpServletRequest request) {
        FirebasePrincipal principal = SecurityUtils.requirePrincipal();
        String provider = principal.signInProvider();
        if (!GOOGLE_PROVIDER.equals(provider)) {
            ApiError body = ApiError.of(
                    HttpStatus.UNAUTHORIZED.value(),
                    HttpStatus.UNAUTHORIZED.getReasonPhrase(),
                    "Expected Google Sign-In token but got provider: "
                            + (provider == null ? "unknown" : provider),
                    request.getRequestURI());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(body);
        }
        return ResponseEntity.ok(new GoogleSignInDto(
                principal.uid(),
                principal.email(),
                principal.name(),
                provider));
    }
}
