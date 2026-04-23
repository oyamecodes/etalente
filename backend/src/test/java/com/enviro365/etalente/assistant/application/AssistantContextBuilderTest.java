package com.enviro365.etalente.assistant.application;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Duration;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.IntStream;

import org.junit.jupiter.api.Test;

import com.enviro365.etalente.assistant.config.AssistantProperties;
import com.enviro365.etalente.jobs.domain.EmploymentType;
import com.enviro365.etalente.jobs.domain.Job;
import com.enviro365.etalente.jobs.domain.JobRepository;
import com.enviro365.etalente.stats.application.StatsService;
import com.enviro365.etalente.stats.dto.StatsDto;

/**
 * Unit tests for {@link AssistantContextBuilder}. Verifies that the live
 * site context (stats + job snapshot) is injected into the system prompt
 * and that the builder is defensive against upstream failures.
 */
class AssistantContextBuilderTest {

    private static final AssistantProperties PROPS = new AssistantProperties(
            "canned", null, null, null, Duration.ofSeconds(5), "BASE_PROMPT");

    @Test
    void appendsStatsAndJobsToSystemPrompt() {
        StatsService stats = new StatsService() {
            @Override public StatsDto current() { return new StatsDto(7, 21, 2); }
        };
        JobRepository jobs = repoOf(List.of(job("Senior Java Engineer", "Cape Town")));

        String ctx = new AssistantContextBuilder(PROPS, stats, jobs).build();

        assertThat(ctx).startsWith("BASE_PROMPT");
        assertThat(ctx).contains("CURRENT_SITE_CONTEXT:");
        assertThat(ctx).contains("7 active posts, 21 new applicants, 2 interviews today");
        assertThat(ctx).contains("Senior Java Engineer");
        assertThat(ctx).contains("Cape Town");
    }

    @Test
    void cappsJobListAtMaxJobsInContext() {
        JobRepository jobs = repoOf(IntStream.range(0, 20)
                .mapToObj(i -> job("Role " + i, "Joburg"))
                .toList());

        String ctx = new AssistantContextBuilder(PROPS, new StatsService(), jobs).build();

        // Only first 8 rendered; "Role 8".."Role 19" absent.
        assertThat(ctx).contains("Role 0").contains("Role 7");
        assertThat(ctx).doesNotContain("Role 8");
        assertThat(ctx).contains("showing first 8");
    }

    @Test
    void swallowsUpstreamFailuresSoPromptStillBuilds() {
        StatsService brokenStats = new StatsService() {
            @Override public StatsDto current() { throw new RuntimeException("boom"); }
        };
        JobRepository brokenJobs = new JobRepository() {
            @Override public List<Job> findAll() { throw new RuntimeException("boom"); }
            @Override public Optional<Job> findById(String id) { return Optional.empty(); }
        };

        String ctx = new AssistantContextBuilder(PROPS, brokenStats, brokenJobs).build();

        assertThat(ctx).contains("Dashboard stats unavailable");
        assertThat(ctx).contains("Job list unavailable");
    }

    private static JobRepository repoOf(List<Job> jobs) {
        return new JobRepository() {
            @Override public List<Job> findAll() { return jobs; }
            @Override public Optional<Job> findById(String id) {
                return jobs.stream().filter(j -> j.id().equals(id)).findFirst();
            }
        };
    }

    private static Job job(String title, String location) {
        return Job.builder()
                .id(title.toLowerCase().replace(' ', '-'))
                .title(title)
                .location(location)
                .type(EmploymentType.FULL_TIME)
                .experience("Senior")
                .minYearsExperience(5)
                .salaryRange("R1m - R1.2m")
                .postedBy("eTalente")
                .closingDate(LocalDate.of(2026, 12, 31))
                .description("desc")
                .skills(List.of("Java"))
                .build();
    }
}
