package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.PhotoChantier;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PhotoChantierRepository extends JpaRepository<PhotoChantier, Long> {
    List<PhotoChantier> findByChantierIdOrderByDateCreationDesc(Long chantierId);
    List<PhotoChantier> findByChantierIdAndVisibleClientTrueOrderByDateCreationDesc(Long chantierId);
}
