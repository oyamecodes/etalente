package com.enviro365.etalente.assistant.api;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.enviro365.etalente.assistant.application.AssistantService;
import com.enviro365.etalente.assistant.dto.AssistantMessageRequest;
import com.enviro365.etalente.assistant.dto.AssistantMessageResponse;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/assistant")
@Tag(name = "Assistant", description = "AI assistant stub (canned reply)")
public class AssistantController {

    private final AssistantService service;

    public AssistantController(AssistantService service) {
        this.service = service;
    }

    @PostMapping("/message")
    @Operation(summary = "Send a message to the assistant")
    public AssistantMessageResponse message(@Valid @RequestBody AssistantMessageRequest request) {
        return service.reply(request);
    }
}
