package com.enviro365.etalente.stats.dto;

/**
 * Dashboard summary payload. Field names and values mirror the example in
 * the assessment brief.
 */
public record StatsDto(int activePosts, int newApplicants, int interviewsToday) {
}
