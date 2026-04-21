package com.enviro365.etalente.security;

import java.util.Optional;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

/**
 * Small helper for controllers/services that need the caller's identity
 * without reaching into Spring Security boilerplate.
 */
public final class SecurityUtils {

    private SecurityUtils() {
    }

    public static Optional<FirebasePrincipal> currentPrincipal() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !auth.isAuthenticated()) {
            return Optional.empty();
        }
        if (auth.getPrincipal() instanceof FirebasePrincipal principal) {
            return Optional.of(principal);
        }
        return Optional.empty();
    }

    public static FirebasePrincipal requirePrincipal() {
        return currentPrincipal().orElseThrow(
                () -> new IllegalStateException("No authenticated principal in security context"));
    }
}
