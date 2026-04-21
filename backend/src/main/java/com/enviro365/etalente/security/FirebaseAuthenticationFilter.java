package com.enviro365.etalente.security;

import java.io.IOException;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Extracts {@code Authorization: Bearer <id-token>}, verifies it against
 * Firebase, and populates the {@link SecurityContextHolder} on success.
 *
 * <p>On failure the request is allowed to continue with an empty security
 * context — the downstream {@code SecurityFilterChain} will reject it with
 * 401 via {@link org.springframework.security.web.authentication.Http403ForbiddenEntryPoint}
 * or the configured entry point. This keeps auth failures in one place
 * (the entry point / exception handler) rather than having this filter
 * write HTTP responses itself.</p>
 */
public class FirebaseAuthenticationFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(FirebaseAuthenticationFilter.class);
    private static final String BEARER_PREFIX = "Bearer ";

    private final FirebaseAuth firebaseAuth;

    public FirebaseAuthenticationFilter(FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String header = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(header) && header.startsWith(BEARER_PREFIX)) {
            String idToken = header.substring(BEARER_PREFIX.length()).trim();
            try {
                FirebaseToken token = firebaseAuth.verifyIdToken(idToken);
                FirebasePrincipal principal = new FirebasePrincipal(
                        token.getUid(),
                        token.getEmail(),
                        token.getName(),
                        extractSignInProvider(token));
                SecurityContextHolder.getContext()
                        .setAuthentication(new FirebaseAuthenticationToken(principal));
            } catch (FirebaseAuthException e) {
                log.debug("Rejecting request: invalid Firebase ID token ({})", e.getMessage());
                SecurityContextHolder.clearContext();
            }
        }
        filterChain.doFilter(request, response);
    }

    /**
     * Pulls {@code firebase.sign_in_provider} out of the verified token's
     * custom claims. Firebase nests provider info under the {@code "firebase"}
     * claim (e.g. {@code {"sign_in_provider": "google.com", "identities": {...}}}).
     * Returns {@code null} if the claim is absent or malformed so callers can
     * treat "unknown provider" uniformly.
     */
    @SuppressWarnings("unchecked")
    private static String extractSignInProvider(FirebaseToken token) {
        Object firebaseClaim = token.getClaims().get("firebase");
        if (firebaseClaim instanceof Map<?, ?> map) {
            Object provider = ((Map<String, Object>) map).get("sign_in_provider");
            if (provider instanceof String s && !s.isBlank()) {
                return s;
            }
        }
        return null;
    }
}
