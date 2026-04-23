package com.enviro365.etalente.stats.application;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

import com.enviro365.etalente.config.CachingConfig;
import com.enviro365.etalente.stats.dto.StatsDto;

/**
 * Supplies dashboard stats. Values are hardcoded to match the brief; a real
 * implementation would aggregate from the jobs and applications stores.
 *
 * <p>Cached so repeated dashboard loads don't re-build the DTO. In a real
 * deployment the cache would be evicted on relevant writes (new job,
 * applicant activity); for the mock there is nothing to invalidate.</p>
 */
@Service
public class StatsService {

    @Cacheable(CachingConfig.STATS)
    public StatsDto current() {
        return new StatsDto(12, 48, 3);
    }
}
