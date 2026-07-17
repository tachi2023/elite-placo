package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerFicheMetrageRequest;
import com.eliteplaco.api.dto.PieceMetrageRequest;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.service.MetrageService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

/** Endpoints REST du Module 5 (fiche de métrage numérique). */
@RestController
@RequestMapping("/api/chantiers/{chantierId}/fiches-metrage")
public class MetrageController {

    private final MetrageService metrageService;
    public MetrageController(MetrageService metrageService) { this.metrageService = metrageService; }

    @PostMapping
    public FicheMetrage creer(@PathVariable Long chantierId, @Valid @RequestBody CreerFicheMetrageRequest requete) {
        return metrageService.creerFiche(chantierId, FicheMetrage.SystemePlatrerie.valueOf(requete.systeme()));
    }

    @PostMapping("/{ficheId}/pieces")
    public FicheMetrage ajouterPiece(@PathVariable Long ficheId, @Valid @RequestBody PieceMetrageRequest requete) {
        return metrageService.ajouterPiece(ficheId, requete);
    }

    @PostMapping("/{ficheId}/valider")
    public FicheMetrage valider(@PathVariable Long ficheId) {
        return metrageService.valider(ficheId);
    }
}
