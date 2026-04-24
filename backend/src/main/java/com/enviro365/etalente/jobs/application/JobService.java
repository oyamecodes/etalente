package com.enviro365.etalente.jobs.application;

import java.util.List;
import java.util.Locale;
import java.util.function.Predicate;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.enviro365.etalente.common.error.ResourceNotFoundException;
import com.enviro365.etalente.common.web.PageResponse;
import com.enviro365.etalente.config.CachingConfig;
import com.enviro365.etalente.jobs.domain.EmploymentType;
import com.enviro365.etalente.jobs.domain.Job;
import com.enviro365.etalente.jobs.domain.JobRepository;
import com.enviro365.etalente.jobs.dto.JobDetailDto;
import com.enviro365.etalente.jobs.dto.JobDto;
import com.enviro365.etalente.jobs.dto.JobMapper;

/**
 * Application service for job listings. All filtering, searching, and
 * pagination happens here so controllers stay thin and the logic is easy
 * to unit-test without spinning up a web context.
 */
@Service
public class JobService {

    private final JobRepository repository;

    public JobService(JobRepository repository) {
        this.repository = repository;
    }

    /**
     * Paged + filtered job list. Cached on the full {@link JobQuery}
     * record so different filter combinations each get their own entry;
     * invalidated manually when the repository grows write support.
     */
    @Cacheable(CachingConfig.JOBS_LIST)
    public PageResponse<JobDto> list(JobQuery query) {
        Predicate<Job> filter = buildFilter(query);

        List<Job> matched = repository.findAll().stream()
                .filter(filter)
                .toList();

        int fromIndex = Math.min(query.page() * query.size(), matched.size());
        int toIndex = Math.min(fromIndex + query.size(), matched.size());
        List<JobDto> pageContent = matched.subList(fromIndex, toIndex).stream()
                .map(JobMapper::toDto)
                .toList();

        return PageResponse.of(pageContent, query.page(), query.size(), matched.size());
    }

    @Cacheable(CachingConfig.JOBS_BY_ID)
    public JobDetailDto findById(String id) {
        return repository.findById(id)
                .map(JobMapper::toDetailDto)
                .orElseThrow(() -> new ResourceNotFoundException("Job not found: " + id));
    }

    // ---------------------------------------------------------------------
    // Filter construction
    // ---------------------------------------------------------------------

    private Predicate<Job> buildFilter(JobQuery q) {
        Predicate<Job> predicate = job -> true;

        if (StringUtils.hasText(q.type())) {
            EmploymentType wanted = EmploymentType.fromWire(q.type().trim());
            predicate = predicate.and(job -> job.type() == wanted);
        }

        if (StringUtils.hasText(q.location())) {
            String needle = q.location().trim().toLowerCase(Locale.ROOT);
            predicate = predicate.and(job -> job.location() != null
                    && job.location().toLowerCase(Locale.ROOT).contains(needle));
        }

        if (StringUtils.hasText(q.experience())) {
            int minYears = parseExperience(q.experience().trim());
            predicate = predicate.and(job -> job.minYearsExperience() >= minYears);
        }

        if (StringUtils.hasText(q.search())) {
            String needle = q.search().trim().toLowerCase(Locale.ROOT);
            predicate = predicate.and(job -> matchesSearch(job, needle));
        }

        return predicate;
    }

    /**
     * Accepts either a plain integer ({@code "3"}) or a wire-form minimum
     * experience ({@code "3+ Years"}, {@code "5+"}). Throws
     * {@link IllegalArgumentException} on anything else — surfaced to the
     * client as 400 by the global handler.
     */
    static int parseExperience(String raw) {
        StringBuilder digits = new StringBuilder();
        for (char c : raw.toCharArray()) {
            if (Character.isDigit(c)) {
                digits.append(c);
            } else if (!digits.isEmpty()) {
                break;
            }
        }
        if (digits.isEmpty()) {
            throw new IllegalArgumentException("Invalid experience filter: " + raw);
        }
        return Integer.parseInt(digits.toString());
    }

    private static boolean matchesSearch(Job job, String needle) {
        if (containsIgnoreCase(job.title(), needle)) return true;
        if (containsIgnoreCase(job.company(), needle)) return true;
        if (containsIgnoreCase(job.location(), needle)) return true;
        if (containsIgnoreCase(job.description(), needle)) return true;
        if (job.skills() != null) {
            for (String skill : job.skills()) {
                if (containsIgnoreCase(skill, needle)) return true;
            }
        }
        return false;
    }

    private static boolean containsIgnoreCase(String haystack, String needle) {
        return haystack != null && haystack.toLowerCase(Locale.ROOT).contains(needle);
    }
}
