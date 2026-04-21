package com.enviro365.etalente.stats.api;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.stats.application.StatsService;
import com.enviro365.etalente.stats.dto.StatsDto;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

@RestController
@RequestMapping("/api/stats")
@Tag(name = "Stats", description = "Dashboard summary numbers")
public class StatsController {

    private final StatsService service;

    public StatsController(StatsService service) {
        this.service = service;
    }

    @GetMapping
    @Operation(summary = "Current dashboard stats")
    public StatsDto current() {
        return service.current();
    }
}
