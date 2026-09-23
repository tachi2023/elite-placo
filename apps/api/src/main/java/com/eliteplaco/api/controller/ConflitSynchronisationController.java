package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.ConflitSynchronisationDTO;
import com.eliteplaco.api.dto.ModifierConflitRequest;
import com.eliteplaco.api.service.ConflitSynchronisationService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/synchronisation/conflits")
public class ConflitSynchronisationController {

    private final ConflitSynchronisationService conflitService;

    public ConflitSynchronisationController(ConflitSynchronisationService conflitService) {
        this.conflitService = conflitService;
    }

    @GetMapping
    public List<ConflitSynchronisationDTO> listerOuverts() {
        return conflitService.listerOuverts();
    }

    @PatchMapping("/{id}")
    public ConflitSynchronisationDTO modifierStatut(@PathVariable Long id,
                                                     @Valid @RequestBody ModifierConflitRequest requete) {
        return conflitService.modifierStatut(id, requete);
    }
}
