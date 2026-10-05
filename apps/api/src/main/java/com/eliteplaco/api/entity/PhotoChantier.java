package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "photo_chantier")
@Getter
@Setter
public class PhotoChantier {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "chantier_id", nullable = false)
    private Chantier chantier;
    @Column(nullable = false, length = 1000)
    private String url;
    @Column(name = "public_id", length = 255)
    private String publicId;
    @Column(length = 255)
    private String libelle;
    @Column(name = "avant_apres", length = 20)
    private String avantApres;
    @Column(name = "visible_client", nullable = false)
    private boolean visibleClient = true;
    @Column(name = "date_creation", nullable = false)
    private LocalDateTime dateCreation = LocalDateTime.now();
}
