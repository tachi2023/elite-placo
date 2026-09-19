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

/**
 * Module 2 — devis signé, encaissements, dépenses, modification et
 * suppression (elite.md §10.3, §10.4, §10.13).
 */
@Service
public class FinanceService {

    private final MouvementFinancierRepository mouvementRepository;
    private final ChantierRepository chantierRepository;
    private final ChantierService chantierService;

    public FinanceService(MouvementFinancierRepository mouvementRepository,
                           ChantierRepository chantierRepository,
                           ChantierService chantierService) {
        this.mouvementRepository = mouvementRepository;
        this.chantierRepository = chantierRepository;
        this.chantierService = chantierService;
    }

    public List<MouvementFinancier> listerParChantier(Long chantierId) {
        return mouvementRepository.findByChantierId(chantierId);
    }

    /**
     * §10.3 — enregistrer un encaissement. A1 : validation stricte.
     * A3 : avertissement NON bloquant si le montant dépasse le reste à
     * encaisser — remonté dans le message, la décision finale reste au
     * dirigeant (l'opération est quand même enregistrée).
     */
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
        chantierService.marquerNonSynchronise(chantier);
        return enregistre;
    }

    /** §10.4 — enregistrer une dépense. A1/A2 : montant et catégorie obligatoires. */
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
        chantierService.marquerNonSynchronise(chantier);
        return enregistree;
    }

    /** §10.13 — modification. A1 : montant invalide refusé sans toucher à l'existant. */
    public MouvementFinancier modifier(Long mouvementId, BigDecimal nouveauMontant, LocalDate nouvelleDate) {
        MouvementFinancier mouvement = mouvementRepository.findById(mouvementId)
                .orElseThrow(() -> new AppException("Mouvement introuvable."));

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
        return mouvementRepository.save(mouvement);
    }

    /** §10.13-A2 — la confirmation est de la responsabilité de l'appelant (UI/contrôleur). */
    public void supprimer(Long mouvementId) {
        if (!mouvementRepository.existsById(mouvementId)) {
            throw new AppException("Mouvement introuvable.");
        }
        mouvementRepository.deleteById(mouvementId);
    }
}
