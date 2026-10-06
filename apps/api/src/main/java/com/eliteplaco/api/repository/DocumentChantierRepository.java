package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.DocumentChantier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DocumentChantierRepository extends JpaRepository<DocumentChantier, Long> {
    List<DocumentChantier> findByChantierIdOrderByDateCreationDesc(Long chantierId);
    List<DocumentChantier> findByChantierIdAndVisibleClientTrueOrderByDateCreationDesc(Long chantierId);
}
