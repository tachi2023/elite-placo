package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.DeltaSynchronisationDTO;
import com.eliteplaco.api.dto.MouvementSynchronisationDTO;
import com.eliteplaco.api.dto.OperationSynchronisationDTO;
import com.eliteplaco.api.dto.ResultatOperationSynchronisationDTO;
import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Depense;
import com.eliteplaco.api.entity.Encaissement;
import com.eliteplaco.api.entity.MouvementFinancier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import com.eliteplaco.api.repository.SynchronisationOperationRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

/** Push par lots et pull incrémental pour le mode hors-ligne. */
@Service
public class SynchronisationService {

    private static final int TAILLE_MAX_LOT = 25;

    private final ChantierRepository chantierRepository;
    private final MouvementFinancierRepository mouvementRepository;
    private final ChantierService chantierService;
    private final FinanceService financeService;
    private final SynchronisationOperationRepository operationRepository;

    public SynchronisationService(ChantierRepository chantierRepository,
                                  MouvementFinancierRepository mouvementRepository,
                                  ChantierService chantierService,
                                  FinanceService financeService,
                                  SynchronisationOperationRepository operationRepository) {
        this.chantierRepository = chantierRepository;
        this.mouvementRepository = mouvementRepository;
        this.chantierService = chantierService;
        this.financeService = financeService;
        this.operationRepository = operationRepository;
    }

    public DeltaSynchronisationDTO renvoyerDeltaServeur(LocalDateTime depuis) {
        LocalDateTime maintenant = LocalDateTime.now();
        List<Chantier> chantiers = chantierRepository.findAll().stream()
                .filter(c -> depuis == null || c.getLastModifiedDate() == null
                        || c.getLastModifiedDate().isAfter(depuis))
                .toList();
        List<MouvementFinancier> mouvements = depuis == null
                ? mouvementRepository.findAll()
                : mouvementRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);

        return new DeltaSynchronisationDTO(
                maintenant,
                chantiers.stream().map(chantierService::calculerSituation).toList(),
                mouvements.stream().map(this::versDTO).toList());
    }

    /** Traite un lot limité afin de permettre une reprise après coupure réseau. */
    public List<ResultatOperationSynchronisationDTO> recevoirLotClient(
            List<OperationSynchronisationDTO> operations) {
        if (operations.size() > TAILLE_MAX_LOT) {
            throw new AppException("La synchronisation est limitée à " + TAILLE_MAX_LOT + " opérations par lot.");
        }
        return operations.stream().map(this::traiterOperation).toList();
    }

    private ResultatOperationSynchronisationDTO traiterOperation(OperationSynchronisationDTO operation) {
        var dejaTraitee = operationRepository.findByOperationId(operation.operationId());
        if (dejaTraitee.isPresent()) {
            var resultat = dejaTraitee.get();
            return new ResultatOperationSynchronisationDTO(
                    resultat.getOperationId(), resultat.isSucces(),
                    resultat.getServeurId(), resultat.getMessage());
        }

        ResultatOperationSynchronisationDTO resultat;
        try {
            if ("chantier".equals(operation.entite())) {
                resultat = traiterChantier(operation, operation.donnees());
            } else if ("mouvement".equals(operation.entite())) {
                resultat = traiterMouvement(operation, operation.donnees());
            } else {
                resultat = echec(operation, "Entité de synchronisation inconnue.");
            }
        } catch (RuntimeException ex) {
            resultat = echec(operation, ex.getMessage());
        }
        if (resultat.succes()) {
            operationRepository.save(new com.eliteplaco.api.entity.SynchronisationOperation(
                    resultat.operationId(), true, resultat.serveurId(), null));
        }
        return resultat;
    }

    private ResultatOperationSynchronisationDTO traiterChantier(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        if ("CREATION".equals(operation.action())) {
            Chantier chantier = chantierService.creer(
                    texte(donnees, "nomClient"), texteOptionnel(donnees, "ville"),
                    texte(donnees, "typeTravaux"), decimal(donnees, "montantDevis"));
            return succes(operation, chantier.getId());
        }
        if ("MODIFICATION_STATUT".equals(operation.action())) {
            Chantier chantier = chantierService.changerStatut(
                    nombre(donnees.get("id")),
                    Chantier.StatutChantier.valueOf(texte(donnees, "statut")),
                    dateHeureOptionnelle(donnees.get("lastModifiedDate")));
            return succes(operation, chantier.getId());
        }
        return echec(operation, "Action chantier non prise en charge.");
    }

    private ResultatOperationSynchronisationDTO traiterMouvement(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        Long chantierId = nombre(donnees.get("chantierId"));
        if ("CREATION_ENCAISSEMENT".equals(operation.action())) {
            Encaissement mouvement = financeService.enregistrerEncaissement(
                    chantierId, decimal(donnees, "montant"), date(donnees, "date"),
                    texteOptionnel(donnees, "nature"));
            return succes(operation, mouvement.getId());
        }
        if ("CREATION_DEPENSE".equals(operation.action())) {
            Depense mouvement = financeService.enregistrerDepense(
                    chantierId, decimal(donnees, "montant"), date(donnees, "date"),
                    categorie(texte(donnees, "categorie")), texteOptionnel(donnees, "description"));
            return succes(operation, mouvement.getId());
        }
        if ("MODIFICATION_MOUVEMENT".equals(operation.action())) {
            MouvementFinancier mouvement = financeService.modifier(
                    nombre(donnees.get("id")), decimal(donnees, "montant"), date(donnees, "date"));
            return succes(operation, mouvement.getId());
        }
        if ("SUPPRESSION_MOUVEMENT".equals(operation.action())) {
            Long mouvementId = nombre(donnees.get("id"));
            if (mouvementRepository.existsById(mouvementId)) {
                financeService.supprimer(mouvementId);
            }
            return succes(operation, mouvementId);
        }
        return echec(operation, "Action mouvement non prise en charge.");
    }

    private MouvementSynchronisationDTO versDTO(MouvementFinancier mouvement) {
        String nature = null;
        String categorie = null;
        String description = null;
        if (mouvement instanceof Encaissement encaissement) {
            nature = encaissement.getNature();
        }
        if (mouvement instanceof Depense depense) {
            categorie = depense.getCategorie() == null ? null : depense.getCategorie().name();
            description = depense.getDescription();
        }
        String type = mouvement instanceof Encaissement ? "ENCAISSEMENT" : "DEPENSE";
        return new MouvementSynchronisationDTO(
                mouvement.getId(), mouvement.getChantier().getId(), type,
                mouvement.getDate(), mouvement.getMontant(), nature, categorie,
                description, mouvement.getLastModifiedDate());
    }

    private ResultatOperationSynchronisationDTO succes(OperationSynchronisationDTO operation, Long id) {
        return new ResultatOperationSynchronisationDTO(operation.operationId(), true, id, null);
    }

    private ResultatOperationSynchronisationDTO echec(OperationSynchronisationDTO operation, String message) {
        return new ResultatOperationSynchronisationDTO(operation.operationId(), false, null, message);
    }

    private String texte(Map<String, Object> donnees, String cle) {
        String valeur = texteOptionnel(donnees, cle);
        if (valeur == null || valeur.isBlank()) {
            throw new AppException("Champ de synchronisation manquant : " + cle + ".");
        }
        return valeur;
    }

    private String texteOptionnel(Map<String, Object> donnees, String cle) {
        Object valeur = donnees.get(cle);
        return valeur == null ? null : Objects.toString(valeur);
    }

    private BigDecimal decimal(Map<String, Object> donnees, String cle) {
        Object valeur = donnees.get(cle);
        if (valeur == null) {
            throw new AppException("Champ de synchronisation manquant : " + cle + ".");
        }
        return new BigDecimal(Objects.toString(valeur));
    }

    private LocalDate date(Map<String, Object> donnees, String cle) {
        return LocalDate.parse(texte(donnees, cle));
    }

    private LocalDateTime dateHeureOptionnelle(Object valeur) {
        return valeur == null ? null : LocalDateTime.parse(Objects.toString(valeur));
    }

    private CategorieDepense categorie(String valeur) {
        return switch (valeur) {
            case "BA13" -> CategorieDepense.MATERIAUX_BA13;
            case "OSSATURE" -> CategorieDepense.PROFILES_OSSATURE;
            default -> CategorieDepense.valueOf(valeur);
        };
    }

    private Long nombre(Object valeur) {
        if (valeur == null) {
            throw new AppException("Identifiant de synchronisation manquant.");
        }
        return valeur instanceof Number n ? n.longValue() : Long.valueOf(Objects.toString(valeur));
    }
}
