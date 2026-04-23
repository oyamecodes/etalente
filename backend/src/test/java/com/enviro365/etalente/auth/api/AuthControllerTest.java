package com.enviro365.etalente.auth.api;

import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.authentication;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.web.FilterChainProxy;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

import com.enviro365.etalente.security.FirebaseAuthenticationToken;
import com.enviro365.etalente.security.FirebasePrincipal;

/**
 * MVC tests for {@link AuthController}. Runs under {@code app.auth.mode=dev}
 * so the security chain is wired exactly as in production, then overrides
 * the injected principal per-request via {@code spring-security-test} to
 * exercise the provider-matching logic without a real Firebase project.
 */
@SpringBootTest
@TestPropertySource(properties = "app.auth.mode=dev")
class AuthControllerTest {

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private FilterChainProxy springSecurityFilterChain;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .addFilters(springSecurityFilterChain)
                .build();
    }

    private static FirebaseAuthenticationToken tokenFor(String provider) {
        return new FirebaseAuthenticationToken(new FirebasePrincipal(
                "uid-123", "user@example.com", "Test User", provider));
    }

    @Test
    void meReturnsProviderFromPrincipal() throws Exception {
        mockMvc.perform(get("/api/auth/me").with(authentication(tokenFor("google.com"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.uid").value("uid-123"))
                .andExpect(jsonPath("$.email").value("user@example.com"))
                .andExpect(jsonPath("$.signInProvider").value("google.com"));
    }

    @Test
    void meInDevModeSurfacesDevProvider() throws Exception {
        // No override — dev filter injects the static principal with provider "dev".
        mockMvc.perform(get("/api/auth/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.signInProvider").value("dev"));
    }

    @Test
    void googleSignInAcceptsGoogleProvider() throws Exception {
        mockMvc.perform(post("/api/auth/google-signin")
                        .with(authentication(tokenFor("google.com"))))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.uid").value("uid-123"))
                .andExpect(jsonPath("$.email").value("user@example.com"))
                .andExpect(jsonPath("$.signInProvider").value("google.com"));
    }

    @Test
    void googleSignInRejectsPasswordProviderWith401() throws Exception {
        mockMvc.perform(post("/api/auth/google-signin")
                        .with(authentication(tokenFor("password"))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401))
                .andExpect(jsonPath("$.message")
                        .value(org.hamcrest.Matchers.containsString("password")));
    }

    @Test
    void googleSignInRejectsDevPrincipalWith401() throws Exception {
        // The default dev principal carries provider="dev", not "google.com".
        mockMvc.perform(post("/api/auth/google-signin"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.status").value(401));
    }

    @Test
    void googleSignInRejectsMissingProviderWith401() throws Exception {
        mockMvc.perform(post("/api/auth/google-signin")
                        .with(authentication(tokenFor(null))))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.message")
                        .value(org.hamcrest.Matchers.containsString("unknown")));
    }

    @Test
    void loginReturnsMockTokenForAnyValidCredentials() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"talent@etalente.co.za\",\"password\":\"secret123\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("mock-jwt-token"))
                .andExpect(jsonPath("$.user.id").value("1"))
                .andExpect(jsonPath("$.user.email").value("talent@etalente.co.za"))
                .andExpect(jsonPath("$.user.name").value("Recruitment Admin"));
    }

    @Test
    void loginIsPublic_noAuthHeaderRequired() throws Exception {
        // Proves the security chain permits /api/auth/login without a principal.
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"a@b.co\",\"password\":\"pw-1234\"}"))
                .andExpect(status().isOk());
    }

    @Test
    void loginRejectsInvalidEmailWith400() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"not-an-email\",\"password\":\"secret123\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='email')]").exists());
    }

    @Test
    void loginRejectsShortPasswordWith400() throws Exception {
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"email\":\"a@b.co\",\"password\":\"123\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='password')]").exists());
    }

    @Test
    void signUpReturnsMockTokenAndEchoesSubmittedNameAndEmail() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Jane Doe\","
                                + "\"email\":\"jane@etalente.co.za\","
                                + "\"password\":\"secret123\","
                                + "\"confirmPassword\":\"secret123\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("mock-jwt-token"))
                .andExpect(jsonPath("$.user.id").value("1"))
                .andExpect(jsonPath("$.user.email").value("jane@etalente.co.za"))
                .andExpect(jsonPath("$.user.name").value("Jane Doe"));
    }

    @Test
    void signUpIsPublic_noAuthHeaderRequired() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"A B\","
                                + "\"email\":\"a@b.co\","
                                + "\"password\":\"pw-1234\","
                                + "\"confirmPassword\":\"pw-1234\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isOk());
    }

    @Test
    void signUpRejectsBlankNameWith400() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"\","
                                + "\"email\":\"a@b.co\","
                                + "\"password\":\"pw-1234\","
                                + "\"confirmPassword\":\"pw-1234\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='name')]").exists());
    }

    @Test
    void signUpRejectsInvalidEmailWith400() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Jane\","
                                + "\"email\":\"not-an-email\","
                                + "\"password\":\"pw-1234\","
                                + "\"confirmPassword\":\"pw-1234\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='email')]").exists());
    }

    @Test
    void signUpRejectsShortPasswordWith400() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Jane\","
                                + "\"email\":\"a@b.co\","
                                + "\"password\":\"123\","
                                + "\"confirmPassword\":\"123\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='password')]").exists());
    }

    @Test
    void signUpRejectsMismatchedConfirmPasswordWith400() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Jane\","
                                + "\"email\":\"a@b.co\","
                                + "\"password\":\"secret123\","
                                + "\"confirmPassword\":\"secret999\","
                                + "\"acceptTerms\":true}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='confirmPassword')]").exists());
    }

    @Test
    void signUpRejectsUnacceptedTermsWith400() throws Exception {
        mockMvc.perform(post("/api/auth/signup")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Jane\","
                                + "\"email\":\"a@b.co\","
                                + "\"password\":\"secret123\","
                                + "\"confirmPassword\":\"secret123\","
                                + "\"acceptTerms\":false}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors[?(@.field=='acceptTerms')]").exists());
    }
}
