package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.Utilisateur;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UtilisateurRepository extends JpaRepository<Utilisateur, Long> {
    Optional<Utilisateur> findByIdentifiant(String identifiant);
}
