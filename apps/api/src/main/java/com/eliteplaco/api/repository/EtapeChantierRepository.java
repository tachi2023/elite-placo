package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.EtapeChantier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface EtapeChantierRepository extends JpaRepository<EtapeChantier, Long> {
    List<EtapeChantier> findByChantierIdOrderByOrdreAsc(Long chantierId);
}
