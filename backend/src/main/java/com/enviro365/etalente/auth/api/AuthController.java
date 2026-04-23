package com.enviro365.etalente.auth.api;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.auth.dto.GoogleSignInDto;
import com.enviro365.etalente.auth.dto.LoginRequest;
import com.enviro365.etalente.auth.dto.LoginResponse;
import com.enviro365.etalente.auth.dto.LoginUserDto;
import com.enviro365.etalente.auth.dto.MeDto;
import com.enviro365.etalente.auth.dto.SignUpRequest;
import com.enviro365.etalente.common.error.ApiError;

import java.util.List;
import com.enviro365.etalente.security.FirebasePrincipal;
import com.enviro365.etalente.security.SecurityUtils;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

/**
 * Auth endpoints.
 *
 * <ul>
 *   <li>{@link #login(LoginRequest)} — public mock login per the
 *       assessment spec; returns a static {@code mock-jwt-token} for any
 *       valid email/password pair.</li>
 *   <li>{@link #me()} / {@link #googleSignIn(HttpServletRequest)} — real
 *       Firebase-verified endpoints used by the production flow.</li>
 * </ul>
 */
@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "Caller identity derived from the Firebase ID token")
@SecurityRequirement(name = "bearer-jwt")
public class AuthController {

    static final String GOOGLE_PROVIDER = "google.com";
    static final String MOCK_TOKEN = "mock-jwt-token";
    static final String MOCK_USER_ID = "1";
    static final String MOCK_USER_NAME = "Recruitment Admin";

    /**
     * Mocked sign-in. Returns a static token and a canned user for any
     * syntactically valid credentials — there is no password check,
     * by design of the assessment spec. Kept public (unauthenticated)
     * via {@link com.enviro365.etalente.config.SecurityConfig}.
     */
    @PostMapping("/login")
    @Operation(summary = "Mock credential login (spec-compliant, not production auth)")
    @ApiResponse(responseCode = "200", description = "Always succeeds for valid input")
    public LoginResponse login(@Valid @RequestBody LoginRequest body) {
        return new LoginResponse(
                MOCK_TOKEN,
                new LoginUserDto(MOCK_USER_ID, body.email(), MOCK_USER_NAME));
    }

    /**
     * Mocked sign-up. Mirrors {@link #login} in behaviour — any syntactically
     * valid payload succeeds with the same static token, but the returned
     * user echoes the submitted {@code name} and {@code email} so the client
     * can land on a personalised home screen without a second round-trip.
     * No persistence: re-submitting the same email is not a conflict.
     *
     * <p>Kept public via {@link com.enviro365.etalente.config.SecurityConfig}.
     * {@code confirmPassword} equality is checked here rather than with a
     * class-level constraint so the rejection surfaces as a
     * {@code fieldErrors} entry keyed on {@code confirmPassword}, matching
     * how Bean Validation reports the other field-level failures.</p>
     */
    @PostMapping("/signup")
    @Operation(summary = "Mock credential sign-up (spec-compliant, not production auth)")
    @ApiResponse(responseCode = "200", description = "Always succeeds for valid input")
    @ApiResponse(responseCode = "400", description = "Validation failed (invalid email, short password, mismatched confirmation, terms not accepted)")
    public ResponseEntity<?> signUp(@Valid @RequestBody SignUpRequest body,
                                    HttpServletRequest request) {
        if (!body.password().equals(body.confirmPassword())) {
            ApiError error = ApiError.of(
                    HttpStatus.BAD_REQUEST.value(),
                    HttpStatus.BAD_REQUEST.getReasonPhrase(),
                    "Request validation failed",
                    request.getRequestURI(),
                    List.of(new ApiError.FieldIssue(
                            "confirmPassword", "Passwords do not match")));
            return ResponseEntity.badRequest().body(error);
        }
        LoginResponse response = new LoginResponse(
                MOCK_TOKEN,
                new LoginUserDto(MOCK_USER_ID, body.email(), body.name()));
        return ResponseEntity.ok(response);
    }

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
