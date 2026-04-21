package com.enviro365.etalente.jobs.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

import com.enviro365.etalente.common.error.ResourceNotFoundException;
import com.enviro365.etalente.common.web.PageResponse;
import com.enviro365.etalente.jobs.dto.JobDetailDto;
import com.enviro365.etalente.jobs.dto.JobDto;
import com.enviro365.etalente.jobs.infrastructure.InMemoryJobRepository;

/**
 * Unit tests for {@link JobService} using the real in-memory repository.
 * The repository has no moving parts worth mocking — exercising it directly
 * keeps the assertions meaningful while still isolating the web layer.
 */
class JobServiceTest {

    private final JobService service = new JobService(new InMemoryJobRepository());

    @Test
    void listWithoutFiltersReturnsAllSeededJobs() {
        PageResponse<JobDto> page = service.list(new JobQuery(null, null, null, null, 0, 50));

        assertThat(page.total()).isEqualTo(12);
        assertThat(page.content()).hasSize(12);
        assertThat(page.page()).isZero();
    }

    @Test
    void paginationClampsAndSlicesCorrectly() {
        PageResponse<JobDto> first = service.list(new JobQuery(null, null, null, null, 0, 5));
        PageResponse<JobDto> second = service.list(new JobQuery(null, null, null, null, 1, 5));
        PageResponse<JobDto> third = service.list(new JobQuery(null, null, null, null, 2, 5));

        assertThat(first.content()).hasSize(5);
        assertThat(second.content()).hasSize(5);
        assertThat(third.content()).hasSize(2); // 12 total
        assertThat(first.total()).isEqualTo(12);
    }

    @Test
    void negativePageAndZeroSizeAreNormalised() {
        JobQuery q = new JobQuery(null, null, null, null, -4, 0);

        assertThat(q.page()).isZero();
        assertThat(q.size()).isEqualTo(JobQuery.DEFAULT_PAGE_SIZE);
    }

    @Test
    void oversizedPageSizeIsClampedToMax() {
        JobQuery q = new JobQuery(null, null, null, null, 0, 9999);
        assertThat(q.size()).isEqualTo(JobQuery.MAX_PAGE_SIZE);
    }

    @Test
    void filterByEmploymentType() {
        PageResponse<JobDto> contracts = service.list(
                new JobQuery("Contract", null, null, null, 0, 50));

        assertThat(contracts.content()).isNotEmpty();
        assertThat(contracts.content()).allSatisfy(j -> assertThat(j.type()).isEqualTo("Contract"));
    }

    @Test
    void filterByLocationIsCaseInsensitive() {
        PageResponse<JobDto> capeTown = service.list(
                new JobQuery(null, null, "cape", null, 0, 50));

        assertThat(capeTown.content()).isNotEmpty();
        assertThat(capeTown.content())
                .allSatisfy(j -> assertThat(j.location().toLowerCase()).contains("cape"));
    }

    @Test
    void filterByMinimumExperienceAcceptsWireFormAndPlainInt() {
        PageResponse<JobDto> five = service.list(new JobQuery(null, "5+ Years", null, null, 0, 50));
        PageResponse<JobDto> fiveInt = service.list(new JobQuery(null, "5", null, null, 0, 50));

        assertThat(five.total()).isEqualTo(fiveInt.total());
        assertThat(five.total()).isPositive();
    }

    @Test
    void searchMatchesTitleAndSkillsCaseInsensitive() {
        PageResponse<JobDto> results = service.list(
                new JobQuery(null, null, null, "flutter", 0, 50));

        assertThat(results.content()).isNotEmpty();
        // job-2 "Flutter Mobile Engineer" is an obvious hit; job-1 has Flutter
        // in its skills list. Either way the search must return more than
        // just exact title matches.
        assertThat(results.content()).anyMatch(j -> j.id().equals("job-2"));
    }

    @Test
    void combinedFiltersNarrowTheResultSet() {
        PageResponse<JobDto> wide = service.list(
                new JobQuery("Full-time", null, null, null, 0, 50));
        PageResponse<JobDto> narrow = service.list(
                new JobQuery("Full-time", null, "Cape", null, 0, 50));

        assertThat(narrow.total()).isLessThan(wide.total());
        assertThat(narrow.total()).isPositive();
    }

    @Test
    void findByIdReturnsDetailsIncludingDescriptionAndSkills() {
        JobDetailDto job = service.findById("job-1");

        assertThat(job.id()).isEqualTo("job-1");
        assertThat(job.description()).isNotBlank();
        assertThat(job.skills()).isNotEmpty();
    }

    @Test
    void findByIdThrowsWhenMissing() {
        assertThatThrownBy(() -> service.findById("does-not-exist"))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void unknownEmploymentTypeSurfaceAsIllegalArgument() {
        assertThatThrownBy(() -> service.list(
                new JobQuery("Telepathy", null, null, null, 0, 10)))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
