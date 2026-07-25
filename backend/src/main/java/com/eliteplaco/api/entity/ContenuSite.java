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
    
    public enum TypeContenu {
        REALISATION,
        SERVICE,
        PARAMETRE_GLOBAL
    }
}
