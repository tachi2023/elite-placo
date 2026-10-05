package com.eliteplaco.api.controller;

import com.eliteplaco.api.dto.MediaChantierDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.DocumentChantier;
import com.eliteplaco.api.entity.PhotoChantier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.DocumentChantierRepository;
import com.eliteplaco.api.repository.PhotoChantierRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chantiers/{chantierId}/medias")
@PreAuthorize("isAuthenticated()")
public class MediaChantierController {
    private final ChantierRepository chantierRepository;
    private final PhotoChantierRepository photoRepository;
    private final DocumentChantierRepository documentRepository;

    public MediaChantierController(ChantierRepository chantierRepository,
                                   PhotoChantierRepository photoRepository,
                                   DocumentChantierRepository documentRepository) {
        this.chantierRepository = chantierRepository;
        this.photoRepository = photoRepository;
        this.documentRepository = documentRepository;
    }

    @GetMapping("/photos")
    public List<MediaChantierDTO> photos(@PathVariable Long chantierId) {
        verifierChantier(chantierId);
        return photoRepository.findByChantierIdOrderByDateCreationDesc(chantierId).stream()
                .map(p -> new MediaChantierDTO(p.getId(), p.getUrl(), p.getPublicId(), p.getLibelle(), p.getAvantApres(), p.isVisibleClient(), p.getDateCreation()))
                .toList();
    }

    @PostMapping("/photos")
    public MediaChantierDTO ajouterPhoto(@PathVariable Long chantierId, @Valid @RequestBody MediaRequest request) {
        PhotoChantier p = new PhotoChantier();
        p.setChantier(verifierChantier(chantierId));
        p.setUrl(request.url());
        p.setPublicId(request.publicId());
        p.setLibelle(request.libelle());
        p.setAvantApres(request.avantApres());
        p.setVisibleClient(request.visibleClient() == null || request.visibleClient());
        p = photoRepository.save(p);
        return new MediaChantierDTO(p.getId(), p.getUrl(), p.getPublicId(), p.getLibelle(), p.getAvantApres(), p.isVisibleClient(), p.getDateCreation());
    }

    @GetMapping("/documents")
    public List<MediaChantierDTO> documents(@PathVariable Long chantierId) {
        verifierChantier(chantierId);
        return documentRepository.findByChantierIdOrderByDateCreationDesc(chantierId).stream()
                .map(d -> new MediaChantierDTO(d.getId(), d.getUrl(), d.getPublicId(), d.getLibelle(), null, d.isVisibleClient(), d.getDateCreation()))
                .toList();
    }

    @PostMapping("/documents")
    public MediaChantierDTO ajouterDocument(@PathVariable Long chantierId, @Valid @RequestBody MediaRequest request) {
        DocumentChantier d = new DocumentChantier();
        d.setChantier(verifierChantier(chantierId));
        d.setUrl(request.url());
        d.setPublicId(request.publicId());
        d.setLibelle(request.libelle());
        d.setVisibleClient(request.visibleClient() == null || request.visibleClient());
        d = documentRepository.save(d);
        return new MediaChantierDTO(d.getId(), d.getUrl(), d.getPublicId(), d.getLibelle(), null, d.isVisibleClient(), d.getDateCreation());
    }

    @PatchMapping("/photos/{id}/visibilite")
    public void visibilitePhoto(@PathVariable Long chantierId, @PathVariable Long id, @RequestParam boolean visible) {
        PhotoChantier p = photoRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Photo introuvable."));
        p.setVisibleClient(visible);
        photoRepository.save(p);
    }

    @PatchMapping("/documents/{id}/visibilite")
    public void visibiliteDocument(@PathVariable Long chantierId, @PathVariable Long id, @RequestParam boolean visible) {
        DocumentChantier d = documentRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Document introuvable."));
        d.setVisibleClient(visible);
        documentRepository.save(d);
    }

    @DeleteMapping("/photos/{id}")
    public void supprimerPhoto(@PathVariable Long chantierId, @PathVariable Long id) {
        PhotoChantier p = photoRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Photo introuvable."));
        photoRepository.delete(p);
    }

    @DeleteMapping("/documents/{id}")
    public void supprimerDocument(@PathVariable Long chantierId, @PathVariable Long id) {
        DocumentChantier d = documentRepository.findById(id).filter(x -> x.getChantier().getId().equals(chantierId))
                .orElseThrow(() -> new AppException("Document introuvable."));
        documentRepository.delete(d);
    }

    private Chantier verifierChantier(Long id) {
        return chantierRepository.findById(id).orElseThrow(() -> new AppException("Chantier introuvable."));
    }

    public record MediaRequest(
            @NotBlank @Size(max = 1000) String url,
            @Size(max = 255) String publicId,
            @Size(max = 255) String libelle,
            @Size(max = 20) String avantApres,
            Boolean visibleClient
    ) {}
}
