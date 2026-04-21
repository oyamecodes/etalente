package com.enviro365.etalente.security;

import java.util.Collection;
import java.util.Collections;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;

/**
 * Spring {@link org.springframework.security.core.Authentication} wrapping a
 * {@link FirebasePrincipal}. Marked authenticated at construction because it
 * is only ever built after the token has already been verified (either by
 * Firebase Admin SDK or the dev-mode filter).
 */
public class FirebaseAuthenticationToken extends AbstractAuthenticationToken {

    private final FirebasePrincipal principal;

    public FirebaseAuthenticationToken(FirebasePrincipal principal) {
        this(principal, Collections.emptyList());
    }

    public FirebaseAuthenticationToken(FirebasePrincipal principal,
                                       Collection<? extends GrantedAuthority> authorities) {
        super(authorities);
        this.principal = principal;
        super.setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        // Token is verified upstream; we do not retain it.
        return "";
    }

    @Override
    public FirebasePrincipal getPrincipal() {
        return principal;
    }

    @Override
    public String getName() {
        return principal.uid();
    }
}
