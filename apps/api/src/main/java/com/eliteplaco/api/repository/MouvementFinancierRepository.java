package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.MouvementFinancier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.time.LocalDateTime;

public interface MouvementFinancierRepository extends JpaRepository<MouvementFinancier, Long> {
    List<MouvementFinancier> findByChantierId(Long chantierId);

    List<MouvementFinancier> findByLastModifiedDateAfterOrderByLastModifiedDateAsc(LocalDateTime since);

    @Query("SELECT COALESCE(SUM(e.montant), 0) FROM Encaissement e WHERE e.chantier.id = :chantierId")
    java.math.BigDecimal sommeEncaissements(Long chantierId);

    @Query("SELECT COALESCE(SUM(d.montant), 0) FROM Depense d WHERE d.chantier.id = :chantierId")
    java.math.BigDecimal sommeDepenses(Long chantierId);

    @Query("SELECT e.chantier.id, COALESCE(SUM(e.montant), 0) FROM Encaissement e GROUP BY e.chantier.id")
    List<Object[]> sommeEncaissementsParChantier();

    @Query("SELECT d.chantier.id, COALESCE(SUM(d.montant), 0) FROM Depense d GROUP BY d.chantier.id")
    List<Object[]> sommeDepensesParChantier();
}
