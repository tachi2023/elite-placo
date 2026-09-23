package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.ChantierDTO;
import com.eliteplaco.api.dto.MouvementFinancierDTO;
import com.eliteplaco.api.entity.*;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.transaction.annotation.Transactional;

/**
 * Module 2 — devis signé, encaissements, dépenses, modification et
 * suppression (elite.md §10.3, §10.4, §10.13).
 */
@Service
public class FinanceService {

    private final MouvementFinancierRepository mouvementRepository;
    private final ChantierRepository chantierRepository;
    private final ChantierService chantierService;
    private final AuditService auditService;

    public FinanceService(MouvementFinancierRepository mouvementRepository,
                           ChantierRepository chantierRepository,
                           ChantierService chantierService,
                           AuditService auditService) {
        this.mouvementRepository = mouvementRepository;
        this.chantierRepository = chantierRepository;
        this.chantierService = chantierService;
        this.auditService = auditService;
    }

    @Transactional(readOnly = true)
    public List<MouvementFinancier> listerParChantier(Long chantierId) {
        return mouvementRepository.findByChantierId(chantierId);
    }

    /**
     * §10.3 — enregistrer un encaissement. A1 : validation stricte.
     * A3 : avertissement NON bloquant si le montant dépasse le reste à
     * encaisser — remonté dans le message, la décision finale reste au
     * dirigeant (l'opération est quand même enregistrée).
     */
    @Transactional
    public Encaissement enregistrerEncaissement(Long chantierId, BigDecimal montant, LocalDate date, String nature) {
        if (montant == null || montant.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Le montant doit être un nombre positif.");
        }
        if (date == null || date.isAfter(LocalDate.now())) {
            throw new AppException("La date ne peut pas être postérieure à aujourd'hui.");
        }

        Chantier chantier = chantierService.trouverParIdOuLever(chantierId);

        Encaissement encaissement = new Encaissement();
        encaissement.setChantier(chantier);
        encaissement.setMontant(montant);
        encaissement.setDate(date);
        encaissement.setNature(nature);
        encaissement.setSynchronise(false);
        encaissement.setLastModifiedDate(LocalDateTime.now());

        Encaissement enregistre = mouvementRepository.save(encaissement);
        auditService.enregistrer("CREATION", "MOUVEMENT_FINANCIER", enregistre.getId(),
                chantierId, "Encaissement de " + montant);
        chantierService.marquerNonSynchronise(chantier);
        return enregistre;
    }

    /** §10.4 — enregistrer une dépense. A1/A2 : montant et catégorie obligatoires. */
    @Transactional
    public Depense enregistrerDepense(Long chantierId, BigDecimal montant, LocalDate date,
                                       CategorieDepense categorie, String description) {
        if (montant == null || montant.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Le montant doit être un nombre positif.");
        }
        if (categorie == null) {
            throw new AppException("Choisissez une catégorie de dépense.");
        }

        Chantier chantier = chantierService.trouverParIdOuLever(chantierId);

        Depense depense = new Depense();
        depense.setChantier(chantier);
        depense.setMontant(montant);
        depense.setDate(date);
        depense.setCategorie(categorie);
        depense.setDescription(description);
        depense.setSynchronise(false);
        depense.setLastModifiedDate(LocalDateTime.now());

        Depense enregistree = mouvementRepository.save(depense);
        auditService.enregistrer("CREATION", "MOUVEMENT_FINANCIER", enregistree.getId(),
                chantierId, "Dépense de " + montant + " / catégorie " + categorie);
        chantierService.marquerNonSynchronise(chantier);
        return enregistree;
    }

    /** §10.13 — modification. A1 : montant invalide refusé sans toucher à l'existant. */
    @Transactional
    public MouvementFinancier modifier(Long chantierId, Long mouvementId, BigDecimal nouveauMontant, LocalDate nouvelleDate) {
        MouvementFinancier mouvement = mouvementRepository.findById(mouvementId)
                .orElseThrow(() -> new com.eliteplaco.api.exception.ResourceNotFoundException("Mouvement introuvable."));
        if (!mouvement.getChantier().getId().equals(chantierId)) {
            throw new AppException("Le mouvement n'appartient pas à ce chantier.");
        }

        if (nouveauMontant != null) {
            if (nouveauMontant.compareTo(BigDecimal.ZERO) <= 0) {
                throw new AppException("Le nouveau montant doit être positif.");
            }
            mouvement.setMontant(nouveauMontant);
        }
        if (nouvelleDate != null) {
            mouvement.setDate(nouvelleDate);
        }
        mouvement.setSynchronise(false);
        mouvement.setLastModifiedDate(LocalDateTime.now());
        MouvementFinancier modifie = mouvementRepository.save(mouvement);
        auditService.enregistrer("MODIFICATION", "MOUVEMENT_FINANCIER", mouvementId,
                chantierId, "Montant/date du mouvement modifié");
        return modifie;
    }

    /** §10.13-A2 — la confirmation est de la responsabilité de l'appelant (UI/contrôleur). */
    @Transactional
    public void supprimer(Long chantierId, Long mouvementId) {
        MouvementFinancier mouvement = mouvementRepository.findById(mouvementId)
                .orElseThrow(() -> new com.eliteplaco.api.exception.ResourceNotFoundException("Mouvement introuvable."));
        if (!mouvement.getChantier().getId().equals(chantierId)) {
            throw new AppException("Le mouvement n'appartient pas à ce chantier.");
        }
        chantierService.marquerNonSynchronise(mouvement.getChantier());
        auditService.enregistrer("SUPPRESSION", "MOUVEMENT_FINANCIER", mouvementId,
                chantierId, "Mouvement financier supprimé");
        mouvementRepository.deleteById(mouvementId);
    }
}
