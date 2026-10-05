package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.ChantierSuiviPublicDTO;
import com.eliteplaco.api.dto.SuiviEtapeDTO;
import com.eliteplaco.api.dto.SuiviMediaDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.EtapeChantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.DocumentChantierRepository;
import com.eliteplaco.api.repository.EtapeChantierRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import com.eliteplaco.api.repository.PhotoChantierRepository;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

/** Vue publique minimale: identite, progression et medias marques visibles. */
@RestController
@RequestMapping("/api/suivi")
public class SuiviClientController {
    private final LienSuiviClientRepository lienRepository;
    private final EtapeChantierRepository etapeRepository;
    private final PhotoChantierRepository photoRepository;
    private final DocumentChantierRepository documentRepository;
    private final Environment env;

    public SuiviClientController(LienSuiviClientRepository lienRepository,
                                 EtapeChantierRepository etapeRepository,
                                 PhotoChantierRepository photoRepository,
                                 DocumentChantierRepository documentRepository,
                                 Environment env) {
        this.lienRepository = lienRepository;
        this.etapeRepository = etapeRepository;
        this.photoRepository = photoRepository;
        this.documentRepository = documentRepository;
        this.env = env;
    }

    @GetMapping("/{code}")
    public ChantierSuiviPublicDTO consulter(@PathVariable String code) {
        if ("true".equalsIgnoreCase(env.getProperty("app.demo.enabled", "false")) && "DEMO-CLIENT".equalsIgnoreCase(code)) {
            return new ChantierSuiviPublicDTO("M. Demo Client", "Douala", "EN_COURS", 42,
                    List.of(new SuiviEtapeDTO("Métrage", 1, EtapeChantier.StatutEtape.TERMINEE, LocalDateTime.now().minusDays(4)),
                            new SuiviEtapeDTO("Ossature", 2, EtapeChantier.StatutEtape.EN_COURS, null)), List.of(), List.of());
        }

        LienSuiviClient lien = lienRepository.findByCodePublicAndActifTrue(code)
                .orElseThrow(() -> new AppException("Ce lien de suivi est introuvable ou n'est plus actif."));
        if (lien.getDateExpiration() != null && lien.getDateExpiration().isBefore(LocalDateTime.now())) {
            throw new AppException("Ce lien de suivi a expiré.");
        }

        Chantier chantier = lien.getChantier();
        List<EtapeChantier> etapes = etapeRepository.findByChantierIdOrderByOrdreAsc(chantier.getId());
        List<SuiviEtapeDTO> etapesPubliques = etapes.stream()
                .map(e -> new SuiviEtapeDTO(e.getLibelle(), e.getOrdre(), e.getStatut(), e.getDateFin())).toList();
        List<SuiviMediaDTO> photos = photoRepository.findByChantierIdAndVisibleClientTrueOrderByDateCreationDesc(chantier.getId()).stream()
                .map(p -> new SuiviMediaDTO(p.getUrl(), p.getLibelle(), p.getAvantApres())).toList();
        List<SuiviMediaDTO> documents = documentRepository.findByChantierIdAndVisibleClientTrueOrderByDateCreationDesc(chantier.getId()).stream()
                .map(d -> new SuiviMediaDTO(d.getUrl(), d.getLibelle(), null)).toList();
        return new ChantierSuiviPublicDTO(chantier.getNomClient(), chantier.getVille(), chantier.getStatut().name(),
                calculerAvancementPublic(chantier, etapes), etapesPubliques, photos, documents);
    }

    private int calculerAvancementPublic(Chantier chantier, List<EtapeChantier> etapes) {
        if (!etapes.isEmpty()) {
            long terminees = etapes.stream().filter(e -> e.getStatut() == EtapeChantier.StatutEtape.TERMINEE).count();
            return (int) Math.round(terminees * 100.0 / etapes.size());
        }
        return chantier.getStatut() == Chantier.StatutChantier.TERMINE || chantier.getStatut() == Chantier.StatutChantier.ARCHIVE ? 100 : 0;
    }
}
