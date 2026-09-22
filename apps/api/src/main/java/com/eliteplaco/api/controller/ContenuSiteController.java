package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.ContenuSiteDTO;
import com.eliteplaco.api.entity.ContenuSite;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ContenuSiteRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/contenu-site")
public class ContenuSiteController {

    private final ContenuSiteRepository repository;

    public ContenuSiteController(ContenuSiteRepository repository) {
        this.repository = repository;
    }

    // Endpoint public pour récupérer le contenu (pour le site vitrine)
    @GetMapping
    public List<ContenuSiteDTO> getTousLesContenus() {
        return repository.findAll().stream()
                .map(ContenuSiteDTO::fromEntity)
                .collect(Collectors.toList());
    }

    @GetMapping("/type/{type}")
    public List<ContenuSiteDTO> getContenusParType(@PathVariable ContenuSite.TypeContenu type) {
        return repository.findByTypeOrderByOrdreAsc(type).stream()
                .map(ContenuSiteDTO::fromEntity)
                .collect(Collectors.toList());
    }

    // Endpoints privés (pour l'application Flutter)
    // À sécuriser avec Spring Security plus tard si nécessaire
    
    @PostMapping
    public ContenuSiteDTO creerContenu(@RequestBody ContenuSiteDTO dto) {
        ContenuSite contenu = new ContenuSite();
        contenu.setType(dto.type());
        contenu.setCle(dto.cle());
        contenu.setTitre(dto.titre());
        contenu.setDescription(dto.description());
        contenu.setImageUrl(dto.imageUrl());
        contenu.setOrdre(dto.ordre());
        
        return ContenuSiteDTO.fromEntity(repository.save(contenu));
    }

    @PutMapping("/{id}")
    public ContenuSiteDTO modifierContenu(@PathVariable Integer id, @RequestBody ContenuSiteDTO dto) {
        ContenuSite contenu = repository.findById(id)
                .orElseThrow(() -> new AppException("Contenu non trouvé avec l'ID: " + id));
        
        contenu.setType(dto.type());
        contenu.setCle(dto.cle());
        contenu.setTitre(dto.titre());
        contenu.setDescription(dto.description());
        contenu.setImageUrl(dto.imageUrl());
        contenu.setOrdre(dto.ordre());
        
        return ContenuSiteDTO.fromEntity(repository.save(contenu));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> supprimerContenu(@PathVariable Integer id) {
        if (!repository.existsById(id)) {
            throw new AppException("Contenu non trouvé avec l'ID: " + id);
        }
        repository.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
