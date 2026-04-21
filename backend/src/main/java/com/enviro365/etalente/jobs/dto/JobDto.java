package com.enviro365.etalente.jobs.dto;

import java.time.LocalDate;

/**
 * List-view representation of a job. Matches the example response in the
 * assessment brief — kept flat on purpose so the Flutter client can render
 * cards without extra lookups.
 */
public record JobDto(
        String id,
        String title,
        String location,
        String type,
        String experience,
        String salaryRange,
        String postedBy,
        LocalDate closingDate) {
}
