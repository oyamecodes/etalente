package com.enviro365.etalente.jobs.api;

import static org.hamcrest.Matchers.greaterThan;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.web.FilterChainProxy;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * MVC tests for the jobs endpoints. Uses the real application context so
 * the dev auth filter, security chain, and exception handler are wired the
 * same way they are in production.
 */
@SpringBootTest
@TestPropertySource(properties = "app.auth.mode=dev")
class JobControllerTest {

    @Autowired
    private WebApplicationContext context;

    @Autowired
    private FilterChainProxy springSecurityFilterChain;

    private MockMvc mockMvc;

    @org.junit.jupiter.api.BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders
                .webAppContextSetup(context)
                .addFilters(springSecurityFilterChain)
                .build();
    }

    @Test
    void listReturnsPagedEnvelope() throws Exception {
        mockMvc.perform(get("/api/jobs").param("page", "0").param("size", "3"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content.length()").value(3))
                .andExpect(jsonPath("$.page").value(0))
                .andExpect(jsonPath("$.size").value(3))
                .andExpect(jsonPath("$.total").value(greaterThan(3)))
                .andExpect(jsonPath("$.totalPages").value(greaterThan(1)));
    }

    @Test
    void listAppliesTypeAndLocationFilters() throws Exception {
        mockMvc.perform(get("/api/jobs")
                        .param("type", "Full-time")
                        .param("location", "Cape"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].type").value("Full-time"))
                .andExpect(jsonPath("$.content[0].location").value(
                        org.hamcrest.Matchers.containsStringIgnoringCase("Cape")));
    }

    @Test
    void detailsReturnsDescriptionAndSkills() throws Exception {
        mockMvc.perform(get("/api/jobs/job-1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value("job-1"))
                .andExpect(jsonPath("$.company").isNotEmpty())
                .andExpect(jsonPath("$.description").isNotEmpty())
                .andExpect(jsonPath("$.skills").isArray());
    }

    @Test
    void listContentExposesCompany() throws Exception {
        mockMvc.perform(get("/api/jobs").param("size", "1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].company").isNotEmpty());
    }

    @Test
    void detailsReturns404ForUnknownId() throws Exception {
        mockMvc.perform(get("/api/jobs/does-not-exist"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    void invalidEmploymentTypeReturns400() throws Exception {
        mockMvc.perform(get("/api/jobs").param("type", "Telepathy"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.status").value(400));
    }
}
