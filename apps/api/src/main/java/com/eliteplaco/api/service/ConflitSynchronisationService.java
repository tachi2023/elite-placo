package com.eliteplaco.api.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.eliteplaco.api.dto.ConflitSynchronisationDTO;
import com.eliteplaco.api.dto.OperationSynchronisationDTO;
import com.eliteplaco.api.dto.ModifierConflitRequest;
import com.eliteplaco.api.entity.ConflitSynchronisation;
import com.eliteplaco.api.repository.ConflitSynchronisationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ConflitSynchronisationService {

    private final ConflitSynchronisationRepository repository;
    private final ObjectMapper objectMapper;

    public ConflitSynchronisationService(ConflitSynchronisationRepository repository, ObjectMapper objectMapper) {
        this.repository = repository;
        this.objectMapper = objectMapper;
    }

    @Transactional
    public void enregistrer(OperationSynchronisationDTO operation, String message) {
        if (repository.findByOperationId(operation.operationId()).isPresent()) {
            return;
        }
        ConflitSynchronisation conflit = new ConflitSynchronisation();
        conflit.setOperationId(operation.operationId());
        conflit.setEntite(operation.entite());
        conflit.setAction(operation.action());
        conflit.setLocalId(operation.localId());
        conflit.setPayloadJson(serialiser(operation.donnees()));
        conflit.setMessage(message == null ? "Conflit de synchronisation." : message);
        repository.save(conflit);
    }

    @Transactional(readOnly = true)
    public List<ConflitSynchronisationDTO> listerOuverts() {
        return repository.findByStatutOrderByDateCreationDesc(ConflitSynchronisation.Statut.OUVERT)
                .stream().map(ConflitSynchronisationDTO::fromEntity).toList();
    }

    @Transactional
    public ConflitSynchronisationDTO modifierStatut(Long id, ModifierConflitRequest requete) {
        ConflitSynchronisation conflit = repository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Conflit de synchronisation introuvable."));
        conflit.setStatut(requete.statut());
        return ConflitSynchronisationDTO.fromEntity(repository.save(conflit));
    }

    private String serialiser(Object donnees) {
        try {
            return objectMapper.writeValueAsString(donnees);
        } catch (JsonProcessingException ex) {
            return "{}";
        }
    }
}
