package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.DeltaSynchronisationDTO;
import com.eliteplaco.api.dto.AffectationOuvrierSynchronisationDTO;
import com.eliteplaco.api.dto.FicheMetrageSynchronisationDTO;
import com.eliteplaco.api.dto.MouvementSynchronisationDTO;
import com.eliteplaco.api.dto.OperationSynchronisationDTO;
import com.eliteplaco.api.dto.OuvrierSynchronisationDTO;
import com.eliteplaco.api.dto.PieceMetrageSynchronisationDTO;
import com.eliteplaco.api.dto.ResultatOperationSynchronisationDTO;
import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Depense;
import com.eliteplaco.api.entity.Encaissement;
import com.eliteplaco.api.entity.MouvementFinancier;
import com.eliteplaco.api.entity.AffectationOuvrier;
import com.eliteplaco.api.entity.FicheMetrage;
import com.eliteplaco.api.entity.Ouvrier;
import com.eliteplaco.api.entity.PieceMetrage;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.exception.ConflictException;
import com.eliteplaco.api.repository.AffectationOuvrierRepository;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.FicheMetrageRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import com.eliteplaco.api.repository.OuvrierRepository;
import com.eliteplaco.api.repository.PieceMetrageRepository;
import com.eliteplaco.api.repository.SynchronisationOperationRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import org.springframework.transaction.annotation.Transactional;

/** Push par lots et pull incrémental pour le mode hors-ligne. */
@Service
public class SynchronisationService {

    private static final int TAILLE_MAX_LOT = 25;

    private final ChantierRepository chantierRepository;
    private final MouvementFinancierRepository mouvementRepository;
    private final ChantierService chantierService;
    private final FinanceService financeService;
    private final SynchronisationOperationRepository operationRepository;
    private final OuvrierRepository ouvrierRepository;
    private final AffectationOuvrierRepository affectationRepository;
    private final FicheMetrageRepository ficheRepository;
    private final PieceMetrageRepository pieceRepository;
    private final OuvrierService ouvrierService;
    private final MetrageService metrageService;
    private final ConflitSynchronisationService conflitService;

    public SynchronisationService(ChantierRepository chantierRepository,
                                  MouvementFinancierRepository mouvementRepository,
                                  ChantierService chantierService,
                                  FinanceService financeService,
                                  SynchronisationOperationRepository operationRepository,
                                  OuvrierRepository ouvrierRepository,
                                  AffectationOuvrierRepository affectationRepository,
                                  FicheMetrageRepository ficheRepository,
                                  PieceMetrageRepository pieceRepository,
                                  OuvrierService ouvrierService,
                                  MetrageService metrageService,
                                  ConflitSynchronisationService conflitService) {
        this.chantierRepository = chantierRepository;
        this.mouvementRepository = mouvementRepository;
        this.chantierService = chantierService;
        this.financeService = financeService;
        this.operationRepository = operationRepository;
        this.ouvrierRepository = ouvrierRepository;
        this.affectationRepository = affectationRepository;
        this.ficheRepository = ficheRepository;
        this.pieceRepository = pieceRepository;
        this.ouvrierService = ouvrierService;
        this.metrageService = metrageService;
        this.conflitService = conflitService;
    }

    public DeltaSynchronisationDTO renvoyerDeltaServeur(LocalDateTime depuis) {
        LocalDateTime maintenant = LocalDateTime.now();
        List<Chantier> chantiers = depuis == null 
                ? chantierRepository.findAll()
                : chantierRepository.findByLastModifiedDateAfter(depuis);
        List<MouvementFinancier> mouvements = depuis == null
                ? mouvementRepository.findAll()
                : mouvementRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);
        List<Ouvrier> ouvriers = depuis == null ? ouvrierRepository.findAll()
                : ouvrierRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);
        List<AffectationOuvrier> affectations = depuis == null ? affectationRepository.findAll()
                : affectationRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);
        List<FicheMetrage> fiches = depuis == null ? ficheRepository.findAll()
                : ficheRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);
        List<PieceMetrage> pieces = depuis == null ? pieceRepository.findAll()
                : pieceRepository.findByLastModifiedDateAfterOrderByLastModifiedDateAsc(depuis);

        return new DeltaSynchronisationDTO(
                maintenant,
                chantiers.stream().map(chantierService::calculerSituation).toList(),
                mouvements.stream().map(this::versDTO).toList(),
                ouvriers.stream().map(this::versDTO).toList(),
                affectations.stream().map(this::versDTO).toList(),
                fiches.stream().map(this::versDTO).toList(),
                pieces.stream().map(this::versDTO).toList());
    }

    /** Traite un lot limité afin de permettre une reprise après coupure réseau. */
    @Transactional
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
            } else if ("ouvrier".equals(operation.entite())) {
                resultat = traiterOuvrier(operation, operation.donnees());
            } else if ("affectation_ouvrier".equals(operation.entite())) {
                resultat = traiterAffectation(operation, operation.donnees());
            } else if ("fiche_metrage".equals(operation.entite())) {
                resultat = traiterFiche(operation, operation.donnees());
            } else if ("piece_metrage".equals(operation.entite())) {
                resultat = traiterPiece(operation, operation.donnees());
            } else {
                resultat = echec(operation, "Entité de synchronisation inconnue.");
            }
        } catch (ConflictException ex) {
            conflitService.enregistrer(operation, ex.getMessage());
            resultat = echec(operation, "Conflit conservé pour résolution manuelle.");
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
                    chantierId, nombre(donnees.get("id")), decimal(donnees, "montant"), date(donnees, "date"));
            return succes(operation, mouvement.getId());
        }
        if ("SUPPRESSION_MOUVEMENT".equals(operation.action())) {
            Long mouvementId = nombre(donnees.get("id"));
            if (mouvementRepository.existsById(mouvementId)) {
                financeService.supprimer(chantierId, mouvementId);
            }
            return succes(operation, mouvementId);
        }
        return echec(operation, "Action mouvement non prise en charge.");
    }

    private ResultatOperationSynchronisationDTO traiterOuvrier(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        if (!"CREATION".equals(operation.action())) {
            return echec(operation, "Seule la création d'un ouvrier est synchronisable pour le moment.");
        }
        Ouvrier ouvrier = ouvrierService.creer(
                texte(donnees, "nomComplet"), texteOptionnel(donnees, "telephone"));
        return succes(operation, ouvrier.getId());
    }

    private ResultatOperationSynchronisationDTO traiterAffectation(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        if (!"CREATION_PAIEMENT".equals(operation.action())) {
            return echec(operation, "Seule la création d'un paiement ouvrier est synchronisable pour le moment.");
        }
        AffectationOuvrier affectation = ouvrierService.enregistrerPaiement(
                nombre(donnees.get("ouvrierId")), nombre(donnees.get("chantierId")),
                decimal(donnees, "montantPaye"), date(donnees, "datePaiement"));
        return succes(operation, affectation.getId());
    }

    private ResultatOperationSynchronisationDTO traiterFiche(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        if (!"CREATION".equals(operation.action())) {
            return echec(operation, "Seule la création d'une fiche de métrage est synchronisable pour le moment.");
        }
        FicheMetrage fiche = metrageService.creerFiche(
                nombre(donnees.get("chantierId")), FicheMetrage.SystemePlatrerie.valueOf(texte(donnees, "systeme")));
        return succes(operation, fiche.getId());
    }

    private ResultatOperationSynchronisationDTO traiterPiece(
            OperationSynchronisationDTO operation, Map<String, Object> donnees) {
        if (!"CREATION".equals(operation.action())) {
            return echec(operation, "Seule la création d'une pièce de métrage est synchronisable pour le moment.");
        }
        Long chantierId = nombre(donnees.get("chantierId"));
        Long ficheId = nombre(donnees.get("ficheId"));
        var fiche = metrageService.ajouterPiece(chantierId, ficheId,
                new com.eliteplaco.api.dto.PieceMetrageRequest(
                        texte(donnees, "nomPiece"), decimal(donnees, "longueur"),
                        decimal(donnees, "largeur"), decimalOptionnelle(donnees, "surfaceDeduction")));
        return succes(operation, fiche.getPieces().get(fiche.getPieces().size() - 1).getId());
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

    private OuvrierSynchronisationDTO versDTO(Ouvrier ouvrier) {
        return new OuvrierSynchronisationDTO(ouvrier.getId(), ouvrier.getNomComplet(),
                ouvrier.getTelephone(), ouvrier.getSynchronise(), ouvrier.getLastModifiedDate());
    }

    private AffectationOuvrierSynchronisationDTO versDTO(AffectationOuvrier affectation) {
        return new AffectationOuvrierSynchronisationDTO(affectation.getId(), affectation.getOuvrier().getId(),
                affectation.getChantier().getId(), affectation.getMontantPaye(), affectation.getDatePaiement(),
                affectation.isSynchronise(), affectation.getLastModifiedDate());
    }

    private FicheMetrageSynchronisationDTO versDTO(FicheMetrage fiche) {
        return new FicheMetrageSynchronisationDTO(fiche.getId(), fiche.getChantier().getId(),
                fiche.getSysteme().name(), fiche.getDateCreation(), fiche.getSynchronise(),
                fiche.getLastModifiedDate(), fiche.getPieces().stream().map(this::versDTO).toList());
    }

    private PieceMetrageSynchronisationDTO versDTO(PieceMetrage piece) {
        return new PieceMetrageSynchronisationDTO(piece.getId(), piece.getFiche().getId(), piece.getNomPiece(),
                piece.getLongueur(), piece.getLargeur(), piece.getSurfaceDeduction(), piece.getOrdre(),
                piece.getSynchronise(),
                piece.getLastModifiedDate());
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

    private BigDecimal decimalOptionnelle(Map<String, Object> donnees, String cle) {
        Object valeur = donnees.get(cle);
        return valeur == null ? BigDecimal.ZERO : new BigDecimal(Objects.toString(valeur));
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
