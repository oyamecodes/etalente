package com.enviro365.etalente.jobs.dto;

import java.time.LocalDate;
import java.util.List;

/**
 * Detail-view representation returned by {@code GET /api/jobs/{id}}. Adds
 * {@code description} and {@code skills} on top of the list projection.
 */
public record JobDetailDto(
        String id,
        String title,
        String location,
        String type,
        String experience,
        String salaryRange,
        String postedBy,
        LocalDate closingDate,
        String description,
        List<String> skills) {
}
