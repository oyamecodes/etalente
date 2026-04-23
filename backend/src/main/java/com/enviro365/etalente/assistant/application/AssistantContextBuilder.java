package com.enviro365.etalente.assistant.application;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import com.enviro365.etalente.assistant.config.AssistantProperties;
import com.enviro365.etalente.jobs.domain.Job;
import com.enviro365.etalente.jobs.domain.JobRepository;
import com.enviro365.etalente.stats.application.StatsService;
import com.enviro365.etalente.stats.dto.StatsDto;

/**
 * Builds the system instruction passed to the LLM on every call. Combines
 * {@link AssistantProperties#systemPrompt()} (static scope + behaviour
 * rules) with a {@code CURRENT_SITE_CONTEXT} block describing the live
 * portal state (dashboard stats, job snapshot) so the model can answer
 * "what's open right now?"-style questions without hallucinating.
 *
 * <p>Kept cheap: reads from the in-memory {@link JobRepository} and the
 * (currently hardcoded) {@link StatsService}. Budgeted at the top N jobs
 * so the prompt stays small.</p>
 */
@Component
public class AssistantContextBuilder {

    /** Keep prompt small — top N jobs with short one-liners. */
    private static final int MAX_JOBS_IN_CONTEXT = 8;

    private final AssistantProperties properties;
    private final StatsService statsService;
    private final JobRepository jobRepository;

    public AssistantContextBuilder(AssistantProperties properties,
                                   StatsService statsService,
                                   JobRepository jobRepository) {
        this.properties = properties;
        this.statsService = statsService;
        this.jobRepository = jobRepository;
    }

    public String build() {
        StringBuilder sb = new StringBuilder(properties.systemPrompt());
        sb.append("\n\nCURRENT_SITE_CONTEXT:\n");
        appendStats(sb);
        appendJobs(sb);
        return sb.toString();
    }

    private void appendStats(StringBuilder sb) {
        try {
            StatsDto stats = statsService.current();
            sb.append("- Dashboard: ")
                    .append(stats.activePosts()).append(" active posts, ")
                    .append(stats.newApplicants()).append(" new applicants, ")
                    .append(stats.interviewsToday()).append(" interviews today.\n");
        } catch (RuntimeException ex) {
            // Context is best-effort; never block a reply on stats.
            sb.append("- Dashboard stats unavailable.\n");
        }
    }

    private void appendJobs(StringBuilder sb) {
        try {
            List<Job> all = jobRepository.findAll();
            sb.append("- Open roles (").append(all.size()).append(" total");
            if (all.size() > MAX_JOBS_IN_CONTEXT) {
                sb.append(", showing first ").append(MAX_JOBS_IN_CONTEXT);
            }
            sb.append("):\n");
            String summary = all.stream()
                    .limit(MAX_JOBS_IN_CONTEXT)
                    .map(this::summariseJob)
                    .collect(Collectors.joining("\n"));
            sb.append(summary);
        } catch (RuntimeException ex) {
            sb.append("- Job list unavailable.");
        }
    }

    private String summariseJob(Job j) {
        return "  * " + j.title()
                + " — " + j.location()
                + ", " + j.type().wire()
                + ", " + j.experience()
                + ", " + j.salaryRange()
                + " (closes " + j.closingDate() + ")";
    }
}
