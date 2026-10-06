package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.EtapeChantierDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.EtapeChantier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.EtapeChantierRepository;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/chantiers/{chantierId}/etapes")
@PreAuthorize("isAuthenticated()")
public class EtapeChantierController {
    private final EtapeChantierRepository etapeRepository;
    private final ChantierRepository chantierRepository;

    public EtapeChantierController(EtapeChantierRepository etapeRepository, ChantierRepository chantierRepository) {
        this.etapeRepository = etapeRepository;
        this.chantierRepository = chantierRepository;
    }

    @GetMapping
    public List<EtapeChantierDTO> lister(@PathVariable Long chantierId) {
        verifierChantier(chantierId);
        return etapeRepository.findByChantierIdOrderByOrdreAsc(chantierId).stream().map(EtapeChantierDTO::fromEntity).toList();
    }

    @PostMapping
    public EtapeChantierDTO creer(@PathVariable Long chantierId, @Valid @RequestBody EtapeChantierDTO dto) {
        EtapeChantier e = new EtapeChantier();
        e.setChantier(verifierChantier(chantierId));
        e.setLibelle(dto.libelle().trim());
        e.setOrdre(dto.ordre());
        e.setStatut(dto.statut() == null ? EtapeChantier.StatutEtape.A_FAIRE : dto.statut());
        e.setDateFin(e.getStatut() == EtapeChantier.StatutEtape.TERMINEE ? LocalDateTime.now() : dto.dateFin());
        return EtapeChantierDTO.fromEntity(etapeRepository.save(e));
    }

    @PutMapping("/{id}")
    public EtapeChantierDTO modifier(@PathVariable Long chantierId, @PathVariable Long id, @Valid @RequestBody EtapeChantierDTO dto) {
        EtapeChantier e = etapeRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Etape introuvable."));
        e.setLibelle(dto.libelle().trim());
        e.setOrdre(dto.ordre());
        e.setStatut(dto.statut() == null ? EtapeChantier.StatutEtape.A_FAIRE : dto.statut());
        e.setDateFin(e.getStatut() == EtapeChantier.StatutEtape.TERMINEE ? (dto.dateFin() == null ? LocalDateTime.now() : dto.dateFin()) : null);
        return EtapeChantierDTO.fromEntity(etapeRepository.save(e));
    }

    @DeleteMapping("/{id}")
    public void supprimer(@PathVariable Long chantierId, @PathVariable Long id) {
        EtapeChantier e = etapeRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Etape introuvable."));
        etapeRepository.delete(e);
    }

    private Chantier verifierChantier(Long id) {
        return chantierRepository.findById(id).orElseThrow(() -> new AppException("Chantier introuvable."));
    }
}
