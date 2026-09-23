package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.AvisClientDTO;
import com.eliteplaco.api.dto.CreerAvisClientRequest;
import com.eliteplaco.api.entity.AvisClient;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.AvisClientRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class AvisClientService {

    private final AvisClientRepository avisRepository;
    private final LienSuiviClientRepository lienRepository;

    public AvisClientService(AvisClientRepository avisRepository, LienSuiviClientRepository lienRepository) {
        this.avisRepository = avisRepository;
        this.lienRepository = lienRepository;
    }

    @Transactional
    public AvisClientDTO creer(CreerAvisClientRequest requete) {
        LienSuiviClient lien = lienRepository.findByCodePublicAndActifTrue(requete.codePublic().trim().toUpperCase())
                .orElseThrow(() -> new AppException("Le code de suivi est invalide ou expiré."));
        AvisClient avis = new AvisClient();
        avis.setChantierId(lien.getChantier().getId());
        avis.setNomClient(requete.nomClient().trim());
        avis.setNote(requete.note());
        avis.setCommentaire(requete.commentaire().trim());
        avis.setStatut(AvisClient.Statut.EN_ATTENTE);
        avis.setDateCreation(LocalDateTime.now());
        return AvisClientDTO.fromEntity(avisRepository.save(avis));
    }

    @Transactional(readOnly = true)
    public List<AvisClientDTO> listerPublics() {
        return avisRepository.findByStatutOrderByDatePublicationDesc(AvisClient.Statut.APPROUVE)
                .stream().map(AvisClientDTO::fromEntity).toList();
    }

    @Transactional(readOnly = true)
    public List<AvisClientDTO> listerPourAdministration() {
        return avisRepository.findAllByOrderByDateCreationDesc().stream()
                .map(AvisClientDTO::fromEntity).toList();
    }

    @Transactional
    public AvisClientDTO moderer(Long id, AvisClient.Statut statut) {
        if (statut == AvisClient.Statut.EN_ATTENTE) {
            throw new AppException("Un avis doit être approuvé ou rejeté.");
        }
        AvisClient avis = avisRepository.findById(id)
                .orElseThrow(() -> new AppException("Avis client introuvable."));
        avis.setStatut(statut);
        avis.setDatePublication(statut == AvisClient.Statut.APPROUVE ? LocalDateTime.now() : null);
        return AvisClientDTO.fromEntity(avisRepository.save(avis));
    }
}
