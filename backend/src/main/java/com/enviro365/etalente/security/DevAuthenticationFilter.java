package com.enviro365.etalente.security;

import java.io.IOException;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import com.enviro365.etalente.config.AuthProperties;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Injects a static {@link FirebasePrincipal} for every request when the
 * application runs with {@code app.auth.mode=dev}.
 *
 * <p>Only wired into the security filter chain in dev mode — see
 * {@code SecurityConfig}. Exists so reviewers and tests can exercise the
 * API without provisioning a Firebase project.</p>
 */
public class DevAuthenticationFilter extends OncePerRequestFilter {

    private final FirebasePrincipal devPrincipal;

    public DevAuthenticationFilter(AuthProperties.DevUser devUser) {
        this.devPrincipal = new FirebasePrincipal(devUser.uid(), devUser.email(), devUser.name());
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (SecurityContextHolder.getContext().getAuthentication() == null) {
            SecurityContextHolder.getContext()
                    .setAuthentication(new FirebaseAuthenticationToken(devPrincipal));
        }
        filterChain.doFilter(request, response);
    }
}
