package com.enviro365.etalente.jobs.domain;

import java.util.List;
import java.util.Optional;

/**
 * Repository abstraction for job postings. Implemented today by an in-memory
 * list; swapping in a JPA implementation later requires only a new
 * {@code @Repository} and no service changes.
 */
public interface JobRepository {

    /** Returns every job in declaration order. */
    List<Job> findAll();

    Optional<Job> findById(String id);
}
