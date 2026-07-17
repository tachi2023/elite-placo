package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.CalculMateriauxRequest;
import com.eliteplaco.api.dto.ResultatMateriauxDTO;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.service.MateriauxService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

/** Endpoint REST du Module 3 (calcul automatique des matériaux). */
@RestController
@RequestMapping("/api/materiaux")
public class MateriauxController {

    private final MateriauxService materiauxService;
    public MateriauxController(MateriauxService materiauxService) { this.materiauxService = materiauxService; }

    @PostMapping("/calculer")
    public ResultatMateriauxDTO calculer(@Valid @RequestBody CalculMateriauxRequest requete) {
        FicheMetrage.SystemePlatrerie systeme = FicheMetrage.SystemePlatrerie.valueOf(requete.systeme());
        return materiauxService.calculer(requete.surfaceM2(), systeme, requete.perimetreM(), requete.prixUnitaires());
    }
}
