package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;
import java.security.SecureRandom;

import org.springframework.transaction.annotation.Transactional;

@Service
public class LienSuiviClientService {

    private final LienSuiviClientRepository lienRepository;
    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final SecureRandom secureRandom = new SecureRandom();

    public LienSuiviClientService(LienSuiviClientRepository lienRepository) {
        this.lienRepository = lienRepository;
    }

    @Transactional
    public String genererOuRecupererLien(Chantier chantier) {
        Optional<LienSuiviClient> existant = lienRepository.findByChantierIdAndActifTrue(chantier.getId());
        if (existant.isPresent()) {
            return existant.get().getCodePublic();
        }

        LienSuiviClient nouveau = new LienSuiviClient();
        nouveau.setChantier(chantier);
        nouveau.setCodePublic(codeAleatoire());
        nouveau.setActif(true);
        nouveau.setDateCreation(LocalDateTime.now());
        
        lienRepository.save(nouveau);
        
        chantier.setCodeAccesClient(nouveau.getCodePublic());
        return nouveau.getCodePublic();
    }

    @Transactional
    public String regenererLien(Chantier chantier) {
        lienRepository.findByChantierIdAndActifTrue(chantier.getId()).ifPresent(lien -> {
            lien.setActif(false);
            lien.setDateRevocation(LocalDateTime.now());
            lienRepository.save(lien);
        });
        return genererOuRecupererLien(chantier);
    }

    @Transactional
    public void revoquerLien(Chantier chantier) {
        lienRepository.findByChantierIdAndActifTrue(chantier.getId()).ifPresent(lien -> {
            lien.setActif(false);
            lien.setDateRevocation(LocalDateTime.now());
            lienRepository.save(lien);
        });
        chantier.setCodeAccesClient(null);
    }

    private String codeAleatoire() {
        StringBuilder code = new StringBuilder(10);
        do {
            code.setLength(0);
            for (int i = 0; i < 10; i++) {
                code.append(ALPHABET.charAt(secureRandom.nextInt(ALPHABET.length())));
            }
        } while (lienRepository.findByCodePublicAndActifTrue(code.toString()).isPresent());
        return code.toString();
    }
}
