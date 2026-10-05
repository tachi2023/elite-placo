package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "etape_chantier")
@Getter
@Setter
public class EtapeChantier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "chantier_id", nullable = false)
    private Chantier chantier;

    @Column(nullable = false, length = 120)
    private String libelle;

    @Column(nullable = false)
    private Integer ordre;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatutEtape statut = StatutEtape.A_FAIRE;

    @Column(name = "date_fin")
    private LocalDateTime dateFin;

    public enum StatutEtape { A_FAIRE, EN_COURS, TERMINEE }
}
