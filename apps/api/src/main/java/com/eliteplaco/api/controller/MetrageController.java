package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CreerFicheMetrageRequest;
import com.eliteplaco.api.dto.FicheMetrageDTO;
import com.eliteplaco.api.dto.PieceMetrageDTO;
import com.eliteplaco.api.dto.PieceMetrageRequest;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.service.MetrageService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

import java.util.stream.Collectors;

/** Endpoints REST du Module 5 (fiche de métrage numérique). */
@RestController
@RequestMapping("/api/chantiers/{chantierId}/fiches-metrage")
public class MetrageController {

    private final MetrageService metrageService;
    public MetrageController(MetrageService metrageService) { this.metrageService = metrageService; }

    @PostMapping
    public FicheMetrageDTO creer(@PathVariable Long chantierId, @Valid @RequestBody CreerFicheMetrageRequest requete) {
        return toDTO(metrageService.creerFiche(chantierId, FicheMetrage.SystemePlatrerie.valueOf(requete.systeme())));
    }

    @PostMapping("/{ficheId}/pieces")
    public FicheMetrageDTO ajouterPiece(@PathVariable Long chantierId, @PathVariable Long ficheId, @Valid @RequestBody PieceMetrageRequest requete) {
        return toDTO(metrageService.ajouterPiece(chantierId, ficheId, requete));
    }

    @PostMapping("/{ficheId}/valider")
    public FicheMetrageDTO valider(@PathVariable Long chantierId, @PathVariable Long ficheId) {
        return toDTO(metrageService.valider(chantierId, ficheId));
    }

    private FicheMetrageDTO toDTO(FicheMetrage fiche) {
        return new FicheMetrageDTO(
                fiche.getId(),
                fiche.getChantier().getId(),
                fiche.getSysteme().name(),
                fiche.getDateCreation(),
                fiche.getPieces().stream().map(p -> new PieceMetrageDTO(
                        p.getId(),
                        p.getNomPiece(),
                        p.getLongueur(),
                        p.getLargeur(),
                        p.getSurfaceDeduction(),
                        p.getOrdre()
                )).collect(Collectors.toList())
        );
    }
}
