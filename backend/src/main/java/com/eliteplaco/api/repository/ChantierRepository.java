package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.Chantier;
import org.springframework.data.jpa.repository.JpaRepository;

// Spring Data génère automatiquement les requêtes CRUD de base (findAll, findById, save...).
public interface ChantierRepository extends JpaRepository<Chantier, Long> {
}
