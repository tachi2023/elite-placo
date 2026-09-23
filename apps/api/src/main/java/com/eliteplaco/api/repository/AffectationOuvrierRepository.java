package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.AffectationOuvrier;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.time.LocalDateTime;

public interface AffectationOuvrierRepository extends JpaRepository<AffectationOuvrier, Long> {
    List<AffectationOuvrier> findByChantierId(Long chantierId);
    List<AffectationOuvrier> findByOuvrierId(Long ouvrierId);
    List<AffectationOuvrier> findByLastModifiedDateAfterOrderByLastModifiedDateAsc(LocalDateTime since);
}
