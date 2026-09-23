package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.PieceMetrageRequest;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.entity.PieceMetrage;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.FicheMetrageRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import org.springframework.transaction.annotation.Transactional;

/**
 * Module 5 — jusqu'à 30 pièces par fiche, déductions, récapitulatif
 * automatique (elite.md §10.6).
 */
@Service
public class MetrageService {

    public static final int LIMITE_PIECES = 30; // §10.6-A2

    private final FicheMetrageRepository ficheRepository;
    private final ChantierService chantierService;

    public MetrageService(FicheMetrageRepository ficheRepository, ChantierService chantierService) {
        this.ficheRepository = ficheRepository;
        this.chantierService = chantierService;
    }

    @Transactional
    public FicheMetrage creerFiche(Long chantierId, FicheMetrage.SystemePlatrerie systeme) {
        Chantier chantier = chantierService.trouverParIdOuLever(chantierId);

        FicheMetrage fiche = new FicheMetrage();
        fiche.setChantier(chantier);
        fiche.setSysteme(systeme);
        fiche.setSynchronise(false);
        fiche.setLastModifiedDate(LocalDateTime.now());
        return ficheRepository.save(fiche);
    }

    /** §10.6, étapes 2-4 + A1/A2 : une pièce invalide n'empêche pas la saisie des autres. */
    @Transactional
    public FicheMetrage ajouterPiece(Long chantierId, Long ficheId, PieceMetrageRequest requete) {
        FicheMetrage fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new AppException("Fiche de métrage introuvable."));
        if (!fiche.getChantier().getId().equals(chantierId)) {
            throw new AppException("La fiche n'appartient pas à ce chantier.");
        }

        if (requete.longueur().compareTo(BigDecimal.ZERO) <= 0 || requete.largeur().compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Longueur et largeur doivent être des nombres positifs pour \"" + requete.nomPiece() + "\".");
        }
        if (fiche.getPieces().size() >= LIMITE_PIECES) {
            throw new AppException("Une fiche de métrage est limitée à " + LIMITE_PIECES + " pièces.");
        }

        PieceMetrage piece = new PieceMetrage();
        piece.setFiche(fiche);
        piece.setNomPiece(requete.nomPiece());
        piece.setLongueur(requete.longueur());
        piece.setLargeur(requete.largeur());
        piece.setSurfaceDeduction(requete.surfaceDeduction() != null ? requete.surfaceDeduction() : BigDecimal.ZERO);
        piece.setOrdre(fiche.getPieces().size() + 1);
        piece.setSynchronise(false);
        piece.setLastModifiedDate(LocalDateTime.now());

        fiche.getPieces().add(piece);
        fiche.setSynchronise(false);
        fiche.setLastModifiedDate(LocalDateTime.now());
        return ficheRepository.save(fiche);
    }

    /** §10.6-A3 — au moins une pièce requise pour valider la fiche. */
    @Transactional
    public FicheMetrage valider(Long chantierId, Long ficheId) {
        FicheMetrage fiche = ficheRepository.findById(ficheId)
                .orElseThrow(() -> new AppException("Fiche de métrage introuvable."));
        if (!fiche.getChantier().getId().equals(chantierId)) {
            throw new AppException("La fiche n'appartient pas à ce chantier.");
        }
        if (fiche.getPieces().isEmpty()) {
            throw new AppException("Ajoutez au moins une pièce avant de valider la fiche.");
        }
        return fiche;
    }

    public BigDecimal surfaceNetteTotale(FicheMetrage fiche) {
        BigDecimal total = BigDecimal.ZERO;
        for (PieceMetrage p : fiche.getPieces()) {
            BigDecimal surfaceBrute = p.getLongueur().multiply(p.getLargeur());
            BigDecimal surfaceNette = surfaceBrute.subtract(p.getSurfaceDeduction()).max(BigDecimal.ZERO);
            total = total.add(surfaceNette);
        }
        return total;
    }
}
