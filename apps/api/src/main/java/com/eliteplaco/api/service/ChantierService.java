package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.ChantierDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Chantier.StatutChantier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import org.springframework.transaction.annotation.Transactional;

/**
 * Module 1 (gestion des chantiers) + calcul de situation financière
 * (Module 2) — elite.md §10.2, §10.9, §10.10.
 *
 * Seuils de marge — hypothèse de travail cohérente avec le prototype
 * d'interfaces déjà validé, À CONFIRMER avec le dirigeant (le cahier des
 * charges ne fixe pas de seuil chiffré) :
 *   VERT   : marge >= 20%
 *   ORANGE : 5% <= marge < 20%
 *   ROUGE  : marge < 5%
 */
@Service
public class ChantierService {

    private static final Map<StatutChantier, List<StatutChantier>> TRANSITIONS_VALIDES = new EnumMap<>(StatutChantier.class);
    static {
        TRANSITIONS_VALIDES.put(StatutChantier.A_VENIR, List.of(StatutChantier.EN_COURS));
        TRANSITIONS_VALIDES.put(StatutChantier.EN_COURS, List.of(StatutChantier.EN_PAUSE, StatutChantier.TERMINE));
        TRANSITIONS_VALIDES.put(StatutChantier.EN_PAUSE, List.of(StatutChantier.EN_COURS));
        TRANSITIONS_VALIDES.put(StatutChantier.TERMINE, List.of(StatutChantier.ARCHIVE));
        TRANSITIONS_VALIDES.put(StatutChantier.ARCHIVE, List.of());
    }

    private final ChantierRepository chantierRepository;
    private final MouvementFinancierRepository mouvementRepository;
    private final LienSuiviClientRepository lienSuiviClientRepository;
    private final AuditService auditService;

    public ChantierService(ChantierRepository chantierRepository,
                            MouvementFinancierRepository mouvementRepository,
                            LienSuiviClientRepository lienSuiviClientRepository,
                            AuditService auditService) {
        this.chantierRepository = chantierRepository;
        this.mouvementRepository = mouvementRepository;
        this.lienSuiviClientRepository = lienSuiviClientRepository;
        this.auditService = auditService;
    }

    public List<Chantier> listerActifs() {
        return chantierRepository.findByStatutNot(StatutChantier.ARCHIVE);
    }

    public Chantier trouverParIdOuLever(Long id) {
        return chantierRepository.findById(id)
                .orElseThrow(() -> new com.eliteplaco.api.exception.ResourceNotFoundException("Chantier introuvable."));
    }

    /** §10.2 — création. A1/A2 : validation stricte avant tout enregistrement. */
    @Transactional
    public Chantier creer(String nomClient, String ville, String typeTravaux, BigDecimal montantDevis) {
        if (nomClient == null || nomClient.isBlank()) {
            throw new AppException("Le nom du client est obligatoire.");
        }
        if (typeTravaux == null || typeTravaux.isBlank()) {
            throw new AppException("Le type de travaux est obligatoire.");
        }
        if (montantDevis == null || montantDevis.compareTo(BigDecimal.ZERO) < 0) {
            throw new AppException("Le montant du devis ne peut pas être négatif.");
        }

        Chantier chantier = new Chantier();
        chantier.setNomClient(nomClient.trim());
        chantier.setVille(ville == null ? null : ville.trim());
        chantier.setTypeTravaux(typeTravaux.trim());
        chantier.setMontantDevis(montantDevis);
        chantier.setStatut(StatutChantier.A_VENIR);
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantier.setSynchronise(false);

        Chantier cree = chantierRepository.save(chantier);
        auditService.enregistrer("CREATION", "CHANTIER", cree.getId(), cree.getId(),
                "Chantier créé pour " + cree.getNomClient());
        return cree;
    }

    /** §10.9 — changement de statut. A1 : pas de saut d'étape autorisé. */
    @Transactional
    public Chantier changerStatut(Long chantierId, StatutChantier nouveauStatut, LocalDateTime clientLastModifiedDate) {
        Chantier chantier = trouverParIdOuLever(chantierId);

        if (clientLastModifiedDate != null && chantier.getLastModifiedDate() != null) {
            // Si la version serveur est plus récente que la version client
            if (chantier.getLastModifiedDate().isAfter(clientLastModifiedDate.plusSeconds(1))) {
                throw new com.eliteplaco.api.exception.ConflictException("CONFLIT : Ce chantier a été modifié par un autre utilisateur depuis votre dernière synchronisation.");
            }
        }

        if (chantier.getStatut() == StatutChantier.ARCHIVE) {
            throw new AppException("Ce chantier est archivé. Désarchivez-le avant de changer son statut.");
        }

        List<StatutChantier> transitionsPermises = TRANSITIONS_VALIDES.get(chantier.getStatut());
        if (transitionsPermises == null || !transitionsPermises.contains(nouveauStatut)) {
            throw new AppException("Transition invalide depuis le statut \"" + chantier.getStatut() + "\".");
        }

        chantier.setStatut(nouveauStatut);
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantier.setSynchronise(false);

        if (nouveauStatut == StatutChantier.TERMINE || nouveauStatut == StatutChantier.ARCHIVE) {
            lienSuiviClientRepository.findByChantierIdAndActifTrue(chantierId).ifPresent(l -> {
                if (l.getDateExpiration() == null) {
                    l.setDateExpiration(LocalDateTime.now().plusDays(30));
                    lienSuiviClientRepository.save(l);
                }
            });
        }

        Chantier modifie = chantierRepository.save(chantier);
        auditService.enregistrer("CHANGEMENT_STATUT", "CHANTIER", chantierId, chantierId,
                "Nouveau statut: " + nouveauStatut);
        return modifie;
    }

    /** §10.10 — archivage : uniquement depuis TERMINE (A1). */
    @Transactional
    public Chantier archiver(Long chantierId) {
        Chantier chantier = trouverParIdOuLever(chantierId);
        if (chantier.getStatut() != StatutChantier.TERMINE) {
            throw new AppException("Seul un chantier \"Terminé\" peut être archivé.");
        }
        chantier.setStatut(StatutChantier.ARCHIVE);
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantier.setSynchronise(false);

        lienSuiviClientRepository.findByChantierIdAndActifTrue(chantierId).ifPresent(l -> {
            if (l.getDateExpiration() == null) {
                l.setDateExpiration(LocalDateTime.now().plusDays(30));
                lienSuiviClientRepository.save(l);
            }
        });

        Chantier archive = chantierRepository.save(chantier);
        auditService.enregistrer("CHANGEMENT_STATUT", "CHANTIER", chantierId, chantierId,
                "Nouveau statut: ARCHIVE");
        return archive;
    }

    /** §10.10-A3 — désarchivage (point ouvert, à confirmer avec le dirigeant). */
    @Transactional
    public Chantier desarchiver(Long chantierId) {
        Chantier chantier = trouverParIdOuLever(chantierId);
        if (chantier.getStatut() != StatutChantier.ARCHIVE) {
            throw new AppException("Ce chantier n'est pas archivé.");
        }
        chantier.setStatut(StatutChantier.TERMINE);
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantier.setSynchronise(false);
        return chantierRepository.save(chantier);
    }

    /** Calcule la situation financière complète d'un chantier (Module 2). */
    public ChantierDTO calculerSituation(Chantier chantier) {
        BigDecimal totalEncaisse = mouvementRepository.sommeEncaissements(chantier.getId());
        BigDecimal totalDepenses = mouvementRepository.sommeDepenses(chantier.getId());
        return calculerSituation(chantier, totalEncaisse, totalDepenses);
    }

    public ChantierDTO calculerSituation(Chantier chantier, BigDecimal totalEncaisse, BigDecimal totalDepenses) {
        BigDecimal resultatNet = totalEncaisse.subtract(totalDepenses);

        BigDecimal margePourcent = BigDecimal.ZERO;
        if (totalEncaisse.compareTo(BigDecimal.ZERO) > 0) {
            margePourcent = resultatNet
                    .divide(totalEncaisse, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
        }

        return new ChantierDTO(
                chantier.getId(), chantier.getNomClient(), chantier.getVille(),
                chantier.getTypeTravaux(), chantier.getStatut().name(), chantier.getMontantDevis(),
                totalEncaisse, totalDepenses, resultatNet, margePourcent, calculerIndicateur(margePourcent),
                chantier.getLastModifiedDate()
        );
    }

    public String calculerIndicateur(BigDecimal margePourcent) {
        if (margePourcent.compareTo(BigDecimal.valueOf(20)) >= 0) return "VERT";
        if (margePourcent.compareTo(BigDecimal.valueOf(5)) >= 0) return "ORANGE";
        return "ROUGE";
    }

    @Transactional
    public void marquerNonSynchronise(Chantier chantier) {
        chantier.setSynchronise(false);
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantierRepository.save(chantier);
    }
}
