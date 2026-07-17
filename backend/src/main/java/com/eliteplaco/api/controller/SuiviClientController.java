package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.ChantierSuiviPublicDTO;
import com.eliteplaco.api.dto.DepensePublicDTO;
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
    public SuiviClientController(LienSuiviClientRepository lienRepository) { this.lienRepository = lienRepository; }

    @GetMapping("/{code}")
    public ChantierSuiviPublicDTO consulter(@PathVariable String code) {
        LienSuiviClient lien = lienRepository.findByCodePublicAndActifTrue(code)
                .orElseThrow(() -> new AppException("Ce lien de suivi est introuvable ou n'est plus actif."));

        Chantier chantier = lien.getChantier();
        int avancement = switch (chantier.getStatut()) {
            case A_VENIR -> 0;
            case EN_COURS -> 50;
            case EN_PAUSE -> 50;
            case TERMINE, ARCHIVE -> 100;
        };

        // Filtrer uniquement les dépenses pour le client final
        List<DepensePublicDTO> depensesPubliques = chantier.getMouvements().stream()
                .filter(m -> m.getTypeMouvement() == MouvementFinancier.TypeMouvement.DEPENSE)
                .map(m -> new DepensePublicDTO(
                        m.getDescription(),
                        m.getCategorie(),
                        m.getMontant(),
                        m.getDate()
                ))
                .collect(Collectors.toList());

        return new ChantierSuiviPublicDTO(
                chantier.getNomClient(), 
                chantier.getVille(), 
                chantier.getStatut().name(), 
                avancement,
                depensesPubliques
        );
    }
}
