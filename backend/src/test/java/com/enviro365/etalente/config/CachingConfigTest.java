package com.enviro365.etalente.config;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.util.List;
import java.util.Optional;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.cache.CacheManager;
import org.springframework.test.context.TestPropertySource;

import com.enviro365.etalente.jobs.application.JobQuery;
import com.enviro365.etalente.jobs.application.JobService;
import com.enviro365.etalente.jobs.domain.EmploymentType;
import com.enviro365.etalente.jobs.domain.Job;
import com.enviro365.etalente.jobs.domain.JobRepository;
import com.enviro365.etalente.stats.application.StatsService;

/**
 * Verifies that the {@link org.springframework.cache.annotation.Cacheable}
 * annotations on {@link JobService} and {@link StatsService} actually cut
 * out repeated work. Uses a {@link MockBean} repository so we can count
 * invocations across calls.
 */
@SpringBootTest
@TestPropertySource(properties = {
        "app.auth.mode=dev",
        "assistant.provider=canned"
})
class CachingConfigTest {

    @Autowired
    private JobService jobService;

    @Autowired
    private StatsService statsService;

    @Autowired
    private CacheManager cacheManager;

    @MockBean
    private JobRepository jobRepository;

    private static final Job SAMPLE = Job.builder()
            .id("job-cache-1")
            .title("Cache Me")
            .location("Cape Town, ZA")
            .type(EmploymentType.FULL_TIME)
            .experience("5+ Years")
            .minYearsExperience(5)
            .salaryRange("R100k - R120k")
            .postedBy("Recruitment Team")
            .closingDate(java.time.LocalDate.of(2026, 6, 30))
            .description("desc")
            .skills(List.of("Java", "Spring"))
            .build();

    @Test
    void findByIdIsCachedAcrossCalls() {
        cacheManager.getCache(CachingConfig.JOBS_BY_ID).clear();
        org.mockito.Mockito.when(jobRepository.findById("job-cache-1"))
                .thenReturn(Optional.of(SAMPLE));

        var first = jobService.findById("job-cache-1");
        var second = jobService.findById("job-cache-1");

        assertThat(first).isSameAs(second);
        verify(jobRepository, times(1)).findById("job-cache-1");
    }

    @Test
    void listIsCachedOnQueryKey() {
        cacheManager.getCache(CachingConfig.JOBS_LIST).clear();
        org.mockito.Mockito.when(jobRepository.findAll()).thenReturn(List.of(SAMPLE));

        JobQuery q = new JobQuery(null, null, null, null, 0, 20);
        jobService.list(q);
        jobService.list(q);

        verify(jobRepository, times(1)).findAll();
    }

    @Test
    void statsCurrentIsCached() {
        cacheManager.getCache(CachingConfig.STATS).clear();
        var a = statsService.current();
        var b = statsService.current();

        // Same identity → the cache is returning the memoised instance
        // rather than calling the method body twice.
        assertThat(a).isSameAs(b);
    }
}
