package com.enviro365.etalente.jobs.infrastructure;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.enviro365.etalente.jobs.domain.Job;
import com.enviro365.etalente.jobs.domain.JobRepository;
import com.enviro365.etalente.seed.MockJobData;

/**
 * In-memory {@link JobRepository}. Backed by {@link MockJobData} at
 * construction time; swap for a JPA or JDBC implementation later without
 * touching services or controllers.
 */
@Repository
public class InMemoryJobRepository implements JobRepository {

    private final List<Job> jobs = List.copyOf(MockJobData.jobs());

    @Override
    public List<Job> findAll() {
        return jobs;
    }

    @Override
    public Optional<Job> findById(String id) {
        if (id == null) {
            return Optional.empty();
        }
        return jobs.stream().filter(job -> job.id().equals(id)).findFirst();
    }
}
