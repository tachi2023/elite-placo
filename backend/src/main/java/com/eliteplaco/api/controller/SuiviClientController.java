package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.ChantierSuiviPublicDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.entity.MouvementFinancier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Endpoint PUBLIC
 * Modifié pour inclure un résumé des dépenses pour rassurer le client final.
 */
@RestController
@RequestMapping("/api/suivi")
public class SuiviClientController {

    private final LienSuiviClientRepository lienRepository;
    private final org.springframework.core.env.Environment env;

    public SuiviClientController(LienSuiviClientRepository lienRepository, org.springframework.core.env.Environment env) {
        this.lienRepository = lienRepository;
        this.env = env;
    }

    @GetMapping("/{code}")
    public ChantierSuiviPublicDTO consulter(@PathVariable String code) {
        // Mode démo : si la variable d'environnement APP_DEMO_ENABLED=true et code=="DEMO-CLIENT",
        // retourner un chantier factice pour permettre la validation du design sans base de données.
        String demoEnabled = env.getProperty("APP_DEMO_ENABLED", "false");
        if ("true".equalsIgnoreCase(demoEnabled) && "DEMO-CLIENT".equalsIgnoreCase(code)) {
            return new ChantierSuiviPublicDTO(
                    "M. Demo Client",
                    "Paris",
                    "EN_COURS",
                    42
            );
        }

        LienSuiviClient lien = lienRepository.findByCodePublicAndActifTrue(code)
                .orElseThrow(() -> new AppException("Ce lien de suivi est introuvable ou n'est plus actif."));

        if (lien.getDateExpiration() != null && lien.getDateExpiration().isBefore(java.time.LocalDateTime.now())) {
            throw new java.lang.RuntimeException("Ce lien de suivi a expiré.");
        }

        Chantier chantier = lien.getChantier();
        int avancement = switch (chantier.getStatut()) {
            case A_VENIR -> 0;
            case EN_COURS -> 50;
            case EN_PAUSE -> 50;
            case TERMINE, ARCHIVE -> 100;
        };

        return new ChantierSuiviPublicDTO(
                chantier.getNomClient(), 
                chantier.getVille(), 
                chantier.getStatut().name(), 
                avancement
        );
    }
}
