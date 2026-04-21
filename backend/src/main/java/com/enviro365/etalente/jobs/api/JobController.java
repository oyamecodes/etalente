package com.enviro365.etalente.jobs.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.common.web.PageResponse;
import com.enviro365.etalente.jobs.application.JobQuery;
import com.enviro365.etalente.jobs.application.JobService;
import com.enviro365.etalente.jobs.dto.JobDetailDto;
import com.enviro365.etalente.jobs.dto.JobDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Read-only job listings API. All filters are optional; paging defaults to
 * {@code page=0, size=20}.
 */
@RestController
@RequestMapping("/api/jobs")
@Tag(name = "Jobs", description = "Job listings served from an in-memory mock dataset")
public class JobController {

    private final JobService service;

    public JobController(JobService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "List jobs with optional filters and pagination")
    public PageResponse<JobDto> list(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String experience,
            @RequestParam(required = false) String location,
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        return service.list(new JobQuery(type, experience, location, search, page, size));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Fetch a single job by id")
    public JobDetailDto findById(@PathVariable String id) {
        return service.findById(id);
    }
}
