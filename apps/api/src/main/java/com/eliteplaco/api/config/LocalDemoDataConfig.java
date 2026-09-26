package com.eliteplaco.api.config;

import com.eliteplaco.api.entity.Chantier;
import com.eliteplaco.api.entity.ContenuSite;
import com.eliteplaco.api.entity.Depense;
import com.eliteplaco.api.entity.Encaissement;
import com.eliteplaco.api.entity.LienSuiviClient;
import com.eliteplaco.api.entity.CategorieDepense;
import com.eliteplaco.api.entity.Utilisateur;
import com.eliteplaco.api.repository.ChantierRepository;
import com.eliteplaco.api.repository.ContenuSiteRepository;
import com.eliteplaco.api.repository.LienSuiviClientRepository;
import com.eliteplaco.api.repository.MouvementFinancierRepository;
import com.eliteplaco.api.repository.UtilisateurRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/** Donnees de demonstration opt-in, protegees par APP_DEMO_ENABLED. */
@Configuration
@ConditionalOnProperty(name = "app.demo.enabled", havingValue = "true")
public class LocalDemoDataConfig {

    @Bean
    CommandLineRunner seedLocalData(
            UtilisateurRepository utilisateurRepository,
            ChantierRepository chantierRepository,
            MouvementFinancierRepository mouvementRepository,
            LienSuiviClientRepository lienRepository,
            ContenuSiteRepository contenuRepository,
            PasswordEncoder passwordEncoder) {
        return args -> {
            if (utilisateurRepository.count() == 0) {
                Utilisateur utilisateur = new Utilisateur();
                utilisateur.setIdentifiant("raoul.michel");
                utilisateur.setMotDePasseHache(passwordEncoder.encode("changeme"));
                utilisateurRepository.save(utilisateur);
            }

            creerChantierSiAbsent(chantierRepository, mouvementRepository, lienRepository,
                        "Villa Bonanjo", "Douala", "Platrerie et decoration interieure",
                        Chantier.StatutChantier.EN_COURS, "VB-2026-014", "15800000",
                        List.of(new BigDecimal("4500000"), new BigDecimal("3200000"), new BigDecimal("1500000")),
                        List.of(new BigDecimal("2100000"), new BigDecimal("2300000"), new BigDecimal("900000")));
            creerChantierSiAbsent(chantierRepository, mouvementRepository, lienRepository,
                        "Hotel Le Meridien", "Douala", "Faux plafonds et revetements muraux",
                        Chantier.StatutChantier.EN_COURS, "HM-2026-009", "26000000",
                        List.of(new BigDecimal("8000000"), new BigDecimal("6000000")),
                        List.of(new BigDecimal("4200000"), new BigDecimal("5100000")));
            creerChantierSiAbsent(chantierRepository, mouvementRepository, lienRepository,
                        "Residence Bonapriso", "Douala", "Decoration interieure sur mesure",
                        Chantier.StatutChantier.A_VENIR, "RB-2026-022", "11200000",
                        List.of(new BigDecimal("3000000")),
                        List.of(new BigDecimal("450000")));
            creerChantierSiAbsent(chantierRepository, mouvementRepository, lienRepository,
                        "Suite Presidentielle", "Kribi", "Faux plafonds decoratifs",
                        Chantier.StatutChantier.EN_PAUSE, "SP-2026-007", "8200000",
                        List.of(new BigDecimal("3500000")),
                        List.of(new BigDecimal("2600000"), new BigDecimal("1300000")));
            creerChantierSiAbsent(chantierRepository, mouvementRepository, lienRepository,
                        "Siege Corporate", "Akwa", "Platrerie et peinture decorative",
                        Chantier.StatutChantier.TERMINE, "SC-2025-041", "9500000",
                        List.of(new BigDecimal("7800000")),
                        List.of(new BigDecimal("3200000"), new BigDecimal("2440000")));

            if (contenuRepository.count() == 0) {
                contenuRepository.saveAll(List.of(
                        contenu(ContenuSite.TypeContenu.PARAMETRE_GLOBAL, "hero_title",
                                "Des espaces qui imposent leur presence.",
                                "Platrerie, plafonds et decoration interieure premium a Douala.", null, 1),
                        contenu(ContenuSite.TypeContenu.SERVICE, "service_platrerie",
                                "Platrerie sur mesure",
                                "Des lignes nettes, des volumes precis, des finitions qui durent.", null, 2),
                        contenu(ContenuSite.TypeContenu.SERVICE, "service_plafonds",
                                "Faux plafonds signatures",
                                "Un plafond pense comme une piece d architecture.", null, 3),
                        contenu(ContenuSite.TypeContenu.REALISATIONS, "realisation_villa",
                                "Villa Bonanjo",
                                "Eclairage indirect et volumes contemporains.", "/assets/realisations/villa.jpg", 4),
                        contenu(ContenuSite.TypeContenu.REALISATIONS, "realisation_hotel",
                                "Hotel Le Meridien",
                                "Un geste precis pour un lieu d exception.", "/assets/realisations/hotel.jpg", 5)
                ));
            }
        };
    }

    private void creerChantierSiAbsent(ChantierRepository chantierRepository,
                               MouvementFinancierRepository mouvementRepository,
                               LienSuiviClientRepository lienRepository,
                               String nomClient, String ville, String travaux,
                               Chantier.StatutChantier statut, String code,
                               String montantDevis, List<BigDecimal> encaissements,
                               List<BigDecimal> depenses) {
        if (chantierRepository.findByCodeAccesClient(code).isPresent()) {
            return;
        }
        creerChantier(chantierRepository, mouvementRepository, lienRepository,
                nomClient, ville, travaux, statut, code, montantDevis, encaissements, depenses);
    }

    private void creerChantier(ChantierRepository chantierRepository,
                               MouvementFinancierRepository mouvementRepository,
                               LienSuiviClientRepository lienRepository,
                               String nomClient, String ville, String travaux,
                               Chantier.StatutChantier statut, String code,
                               String montantDevis, List<BigDecimal> encaissements,
                               List<BigDecimal> depenses) {
        Chantier chantier = new Chantier();
        chantier.setNomClient(nomClient);
        chantier.setVille(ville);
        chantier.setTypeTravaux(travaux);
        chantier.setStatut(statut);
        chantier.setMontantDevis(new BigDecimal(montantDevis));
        chantier.setDateCreation(LocalDateTime.now().minusDays(18));
        chantier.setLastModifiedDate(LocalDateTime.now());
        chantier.setSynchronise(true);
        chantier.setCodeAccesClient(code);
        Chantier saved = chantierRepository.save(chantier);

        int index = 0;
        for (BigDecimal value : encaissements) {
            Encaissement encaissement = new Encaissement();
            encaissement.setChantier(saved);
            encaissement.setMontant(value);
            encaissement.setDate(LocalDate.now().minusDays(15L - index * 5L));
            encaissement.setNature(index == 0 ? "ACOMPTE" : "VERSEMENT");
            encaissement.setSynchronise(true);
            mouvementRepository.save(encaissement);
            index++;
        }

        index = 0;
        for (BigDecimal value : depenses) {
            Depense depense = new Depense();
            depense.setChantier(saved);
            depense.setMontant(value);
            depense.setDate(LocalDate.now().minusDays(13L - index * 4L));
            depense.setCategorie(index == 0 ? CategorieDepense.MATERIAUX_BA13 : CategorieDepense.MAIN_OEUVRE);
            depense.setDescription(index == 0 ? "Materiaux et livraison" : "Equipe de pose");
            depense.setSynchronise(true);
            mouvementRepository.save(depense);
            index++;
        }

        LienSuiviClient lien = new LienSuiviClient();
        lien.setChantier(saved);
        lien.setCodePublic(code);
        lien.setActif(true);
        lien.setDateCreation(LocalDateTime.now());
        lienRepository.save(lien);
    }

    private ContenuSite contenu(ContenuSite.TypeContenu type, String cle, String titre,
                                String description, String imageUrl, int ordre) {
        ContenuSite contenu = new ContenuSite();
        contenu.setType(type);
        contenu.setCle(cle);
        contenu.setTitre(titre);
        contenu.setDescription(description);
        contenu.setImageUrl(imageUrl);
        contenu.setOrdre(ordre);
        return contenu;
    }
}
