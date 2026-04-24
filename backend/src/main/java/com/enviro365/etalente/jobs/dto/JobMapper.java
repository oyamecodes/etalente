package com.enviro365.etalente.jobs.dto;

import com.enviro365.etalente.jobs.domain.Job;

/**
 * Maps {@link Job} domain records to wire DTOs. Static functions — no state,
 * no Spring bean, no runtime cost.
 */
public final class JobMapper {

    private JobMapper() {
    }

    public static JobDto toDto(Job job) {
        return new JobDto(
                job.id(),
                job.title(),
                job.company(),
                job.location(),
                job.type().wire(),
                job.experience(),
                job.salaryRange(),
                job.postedBy(),
                job.closingDate());
    }

    public static JobDetailDto toDetailDto(Job job) {
        return new JobDetailDto(
                job.id(),
                job.title(),
                job.company(),
                job.location(),
                job.type().wire(),
                job.experience(),
                job.salaryRange(),
                job.postedBy(),
                job.closingDate(),
                job.description(),
                job.skills());
    }
}
