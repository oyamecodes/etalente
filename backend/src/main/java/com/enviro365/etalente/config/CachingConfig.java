package com.enviro365.etalente.config;

import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.concurrent.ConcurrentMapCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Minimal in-process caching. Backed by {@link ConcurrentMapCacheManager}
 * so the mock repositories do not take a hit for every identical request
 * (e.g. repeated {@code GET /api/jobs/{id}} from the Flutter client).
 *
 * <p>Caches are named on the annotated method (see
 * {@code JobService#findById} and {@code StatsService#current}). A real
 * deployment would swap this for Caffeine or Redis and add TTLs.</p>
 */
@Configuration
@EnableCaching
public class CachingConfig {

    public static final String JOBS_BY_ID = "jobsById";
    public static final String JOBS_LIST = "jobsList";
    public static final String STATS = "stats";

    @Bean
    public CacheManager cacheManager() {
        return new ConcurrentMapCacheManager(JOBS_BY_ID, JOBS_LIST, STATS);
    }
}
