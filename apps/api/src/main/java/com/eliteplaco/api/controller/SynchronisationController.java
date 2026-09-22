package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.DeltaSynchronisationDTO;
import com.eliteplaco.api.dto.OperationSynchronisationDTO;
import com.eliteplaco.api.dto.ResultatOperationSynchronisationDTO;
import com.eliteplaco.api.service.SynchronisationService;
import jakarta.validation.Valid;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/synchronisation")
public class SynchronisationController {

    private final SynchronisationService synchronisationService;

    public SynchronisationController(SynchronisationService synchronisationService) {
        this.synchronisationService = synchronisationService;
    }

    @GetMapping("/delta")
    public DeltaSynchronisationDTO delta(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime depuis) {
        return synchronisationService.renvoyerDeltaServeur(depuis);
    }

    @PostMapping("/lot")
    public List<ResultatOperationSynchronisationDTO> recevoirLot(
            @Valid @RequestBody List<OperationSynchronisationDTO> operations) {
        return synchronisationService.recevoirLotClient(operations);
    }
}
