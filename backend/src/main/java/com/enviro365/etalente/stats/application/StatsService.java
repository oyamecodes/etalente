package com.enviro365.etalente.stats.application;

import org.springframework.stereotype.Service;

import com.enviro365.etalente.stats.dto.StatsDto;

/**
 * Supplies dashboard stats. Values are hardcoded to match the brief; a real
 * implementation would aggregate from the jobs and applications stores.
 */
@Service
public class StatsService {

    public StatsDto current() {
        return new StatsDto(12, 48, 3);
    }
}
