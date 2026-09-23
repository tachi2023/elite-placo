package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.AvisClientDTO;
import com.eliteplaco.api.dto.CreerAvisClientRequest;
import com.eliteplaco.api.dto.ModerationAvisRequest;
import com.eliteplaco.api.service.AvisClientService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/avis")
public class AvisClientController {

    private final AvisClientService avisService;

    public AvisClientController(AvisClientService avisService) {
        this.avisService = avisService;
    }

    @GetMapping("/public")
    public List<AvisClientDTO> listerPublics() {
        return avisService.listerPublics();
    }

    @PostMapping
    public AvisClientDTO creer(@Valid @RequestBody CreerAvisClientRequest requete) {
        return avisService.creer(requete);
    }

    @GetMapping
    public List<AvisClientDTO> listerPourAdministration() {
        return avisService.listerPourAdministration();
    }

    @PatchMapping("/{id}/statut")
    public AvisClientDTO moderer(@PathVariable Long id, @Valid @RequestBody ModerationAvisRequest requete) {
        return avisService.moderer(id, requete.statut());
    }
}
