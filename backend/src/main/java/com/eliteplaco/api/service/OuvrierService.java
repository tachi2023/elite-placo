package com.eliteplaco.api.service;

import com.eliteplaco.api.entity.*;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.AffectationOuvrierRepository;
import com.eliteplaco.api.repository.OuvrierRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Module 6 — affectation par chantier, paiements, remontée automatique en
 * dépense "main d'œuvre" (elite.md §10.8).
 */
@Service
public class OuvrierService {

    private final OuvrierRepository ouvrierRepository;
    private final AffectationOuvrierRepository affectationRepository;
    private final FinanceService financeService;
    private final ChantierService chantierService;

    public OuvrierService(OuvrierRepository ouvrierRepository,
                           AffectationOuvrierRepository affectationRepository,
                           FinanceService financeService,
                           ChantierService chantierService) {
        this.ouvrierRepository = ouvrierRepository;
        this.affectationRepository = affectationRepository;
        this.financeService = financeService;
        this.chantierService = chantierService;
    }

    public List<Ouvrier> lister() {
        return ouvrierRepository.findAll();
    }

    /** §10.8-A1 — nom obligatoire. */
    public Ouvrier creer(String nomComplet, String telephone) {
        if (nomComplet == null || nomComplet.isBlank()) {
            throw new AppException("Le nom de l'ouvrier est obligatoire.");
        }
        Ouvrier ouvrier = new Ouvrier();
        ouvrier.setNomComplet(nomComplet.trim());
        ouvrier.setTelephone(telephone);
        return ouvrierRepository.save(ouvrier);
    }

    /**
     * §10.8, étapes 4-8 : enregistre le paiement PUIS répercute
     * automatiquement le montant en dépense "main d'œuvre" sur le chantier
     * — ce qui déclenche le recalcul du résultat net et de la marge côté
     * ChantierService/FinanceService, sans double saisie pour l'utilisateur.
     *
     * A2 — montant invalide refusé avant tout enregistrement.
     */
    public AffectationOuvrier enregistrerPaiement(Long ouvrierId, Long chantierId, BigDecimal montant, LocalDate date) {
        if (montant == null || montant.compareTo(BigDecimal.ZERO) <= 0) {
            throw new AppException("Le montant du paiement doit être positif.");
        }
        Ouvrier ouvrier = ouvrierRepository.findById(ouvrierId)
                .orElseThrow(() -> new AppException("Ouvrier introuvable."));
        Chantier chantier = chantierService.trouverParIdOuLever(chantierId);

        AffectationOuvrier affectation = new AffectationOuvrier();
        affectation.setOuvrier(ouvrier);
        affectation.setChantier(chantier);
        affectation.setMontantPaye(montant);
        affectation.setDatePaiement(date);
        affectation.setSynchronise(false);
        AffectationOuvrier enregistree = affectationRepository.save(affectation);

        // Remontée automatique en dépense "main d'œuvre" (étape 8 du scénario).
        financeService.enregistrerDepense(
                chantierId, montant, date, CategorieDepense.MAIN_OEUVRE,
                "Paiement " + ouvrier.getNomComplet() + " (généré automatiquement)"
        );

        return enregistree;
    }

    public BigDecimal totalMainOeuvre(Long chantierId) {
        return affectationRepository.findByChantierId(chantierId).stream()
                .map(AffectationOuvrier::getMontantPaye)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<AffectationOuvrier> historique(Long chantierId) {
        return affectationRepository.findByChantierId(chantierId);
    }
}
