package com.eliteplaco.api.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "contenu_site")
@Data
public class ContenuSite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private TypeContenu type;

    // Utile pour retrouver un paramètre spécifique (ex: "hero_title")
    @Column(name = "cle")
    private String cle;

    private String titre;
    
    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url")
    private String imageUrl;

    private Integer ordre;

    @Column(nullable = false)
    private boolean visible = true;

    @Column(name = "public_id", length = 255)
    private String publicId;
    
    public enum TypeContenu {
        REALISATIONS,
        SERVICE,
        PROJET,
        A_PROPOS,
        PARAMETRE_GLOBAL
    }
}
