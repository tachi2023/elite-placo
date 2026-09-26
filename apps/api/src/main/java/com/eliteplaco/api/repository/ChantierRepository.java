package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.Chantier;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;

// Spring Data génère automatiquement les requêtes CRUD de base (findAll, findById, save...).
public interface ChantierRepository extends JpaRepository<Chantier, Long> {
    List<Chantier> findByStatutNot(Chantier.StatutChantier statut);
    List<Chantier> findByLastModifiedDateAfter(LocalDateTime since);
    Optional<Chantier> findByCodeAccesClient(String codeAccesClient);
}
