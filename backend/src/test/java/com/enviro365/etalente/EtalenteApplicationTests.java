package com.enviro365.etalente;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.TestPropertySource;

@SpringBootTest
@TestPropertySource(properties = "app.auth.mode=dev")
class EtalenteApplicationTests {

    @Test
    void contextLoads() {
        // Smoke test — ensures the Spring context starts with dev auth mode
        // so Firebase credentials are not required.
    }
}
