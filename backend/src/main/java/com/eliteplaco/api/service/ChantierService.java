package com.eliteplaco.api.service;

import com.eliteplaco.api.dto.ChantierDTO;
import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.Chantier.StatutChantier;
import com.eliteplaco.api.exception.AppException;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;

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

    public ChantierService(ChantierRepository chantierRepository,
                            MouvementFinancierRepository mouvementRepository) {
        this.chantierRepository = chantierRepository;
        this.mouvementRepository = mouvementRepository;
    }

    public List<Chantier> listerActifs() {
        return chantierRepository.findAll().stream()
                .filter(c -> c.getStatut() != StatutChantier.ARCHIVE)
                .toList();
    }

    public Chantier trouverParIdOuLever(Long id) {
        return chantierRepository.findById(id)
                .orElseThrow(() -> new AppException("Chantier introuvable."));
    }

    /** §10.2 — création. A1/A2 : validation stricte avant tout enregistrement. */
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
        chantier.setSynchronise(false);

        return chantierRepository.save(chantier);
    }

    /** §10.9 — changement de statut. A1 : pas de saut d'étape autorisé. */
    public Chantier changerStatut(Long chantierId, StatutChantier nouveauStatut) {
        Chantier chantier = trouverParIdOuLever(chantierId);

        if (chantier.getStatut() == StatutChantier.ARCHIVE) {
            throw new AppException("Ce chantier est archivé. Désarchivez-le avant de changer son statut.");
        }

        List<StatutChantier> transitionsPermises = TRANSITIONS_VALIDES.get(chantier.getStatut());
        if (transitionsPermises == null || !transitionsPermises.contains(nouveauStatut)) {
            throw new AppException("Transition invalide depuis le statut \"" + chantier.getStatut() + "\".");
        }

        chantier.setStatut(nouveauStatut);
        chantier.setSynchronise(false);
        return chantierRepository.save(chantier);
    }

    /** §10.10 — archivage : uniquement depuis TERMINE (A1). */
    public Chantier archiver(Long chantierId) {
        Chantier chantier = trouverParIdOuLever(chantierId);
        if (chantier.getStatut() != StatutChantier.TERMINE) {
            throw new AppException("Seul un chantier \"Terminé\" peut être archivé.");
        }
        chantier.setStatut(StatutChantier.ARCHIVE);
        chantier.setSynchronise(false);
        return chantierRepository.save(chantier);
    }

    /** §10.10-A3 — désarchivage (point ouvert, à confirmer avec le dirigeant). */
    public Chantier desarchiver(Long chantierId) {
        Chantier chantier = trouverParIdOuLever(chantierId);
        if (chantier.getStatut() != StatutChantier.ARCHIVE) {
            throw new AppException("Ce chantier n'est pas archivé.");
        }
        chantier.setStatut(StatutChantier.TERMINE);
        chantier.setSynchronise(false);
        return chantierRepository.save(chantier);
    }

    /** Calcule la situation financière complète d'un chantier (Module 2). */
    public ChantierDTO calculerSituation(Chantier chantier) {
        BigDecimal totalEncaisse = mouvementRepository.sommeEncaissements(chantier.getId());
        BigDecimal totalDepenses = mouvementRepository.sommeDepenses(chantier.getId());
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
                totalEncaisse, totalDepenses, resultatNet, margePourcent, calculerIndicateur(margePourcent)
        );
    }

    public String calculerIndicateur(BigDecimal margePourcent) {
        if (margePourcent.compareTo(BigDecimal.valueOf(20)) >= 0) return "VERT";
        if (margePourcent.compareTo(BigDecimal.valueOf(5)) >= 0) return "ORANGE";
        return "ROUGE";
    }

    void marquerNonSynchronise(Chantier chantier) {
        chantier.setSynchronise(false);
        chantierRepository.save(chantier);
    }
}
