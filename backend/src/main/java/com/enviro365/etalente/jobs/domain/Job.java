package com.enviro365.etalente.jobs.domain;

import java.time.LocalDate;
import java.util.List;

import lombok.Builder;

/**
 * Immutable domain model for a job posting.
 *
 * <p>Separate from the transport DTO so the wire contract can evolve
 * independently of the domain. {@link #skills} is used server-side for the
 * "Skills" filter chip and for the {@code search} query parameter; it is not
 * currently exposed on the list response but is returned by the details
 * endpoint.</p>
 */
@Builder
public record Job(
        String id,
        String title,
        String company,
        String location,
        EmploymentType type,
        String experience,
        int minYearsExperience,
        String salaryRange,
        String postedBy,
        LocalDate closingDate,
        String description,
        List<String> skills) {
}
