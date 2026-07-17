package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class LienSuiviClientService {

    private final LienSuiviClientRepository lienRepository;

    public LienSuiviClientService(LienSuiviClientRepository lienRepository) {
        this.lienRepository = lienRepository;
    }

    public String genererOuRecupererLien(Chantier chantier) {
        Optional<LienSuiviClient> existant = lienRepository.findByChantierIdAndActifTrue(chantier.getId());
        if (existant.isPresent()) {
            return existant.get().getCodePublic();
        }

        LienSuiviClient nouveau = new LienSuiviClient();
        nouveau.setChantier(chantier);
        nouveau.setCodePublic(UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        nouveau.setActif(true);
        nouveau.setDateCreation(LocalDateTime.now());
        
        lienRepository.save(nouveau);
        
        chantier.setCodeAccesClient(nouveau.getCodePublic());
        return nouveau.getCodePublic();
    }
}
