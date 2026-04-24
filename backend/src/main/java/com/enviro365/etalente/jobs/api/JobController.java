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
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Read-only job listings API. All filters are optional; paging defaults to
 * {@code page=0, size=20} (max {@code size=100}).
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
    @Operation(summary = "List jobs with optional filters and pagination",
            description = "Filters are applied in order: type, experience, location, search. "
                    + "`page` is clamped to >= 0 and `size` is clamped to [1, 100].")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Paged list of jobs"),
            @ApiResponse(responseCode = "400",
                    description = "Unknown `type` value (not one of Full-time, Contract, Part-time, Internship)"),
    })
    public PageResponse<JobDto> list(
            @Parameter(description = "Employment type wire value", example = "Full-time")
            @RequestParam(required = false) String type,
            @Parameter(description = "Minimum years of experience (\"3\" or \"3+ Years\")", example = "3")
            @RequestParam(required = false) String experience,
            @Parameter(description = "Case-insensitive location substring", example = "Cape Town")
            @RequestParam(required = false) String location,
            @Parameter(description = "Free-text search over title/location/skills", example = "flutter")
            @RequestParam(required = false) String search,
            @Parameter(description = "Zero-based page index", example = "0")
            @RequestParam(defaultValue = "0") int page,
            @Parameter(description = "Page size (1..100)", example = "20")
            @RequestParam(defaultValue = "20") int size) {
        return service.list(new JobQuery(type, experience, location, search, page, size));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Fetch a single job by id")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Job detail payload"),
            @ApiResponse(responseCode = "404", description = "No job exists for the given id"),
    })
    public JobDetailDto findById(@PathVariable String id) {
        return service.findById(id);
    }
}
