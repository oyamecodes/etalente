package com.enviro365.etalente;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point for the eTalente recruitment portal API.
 *
 * <p>The application is intentionally small: a handful of REST endpoints
 * backed by in-memory mock data, with Firebase ID-token verification
 * sitting in front of every {@code /api/**} route.</p>
 */
@SpringBootApplication
public class EtalenteApplication {

    public static void main(String[] args) {
        SpringApplication.run(EtalenteApplication.class, args);
    }
}
