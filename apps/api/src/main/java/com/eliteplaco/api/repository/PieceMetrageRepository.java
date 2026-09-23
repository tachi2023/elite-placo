package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.PieceMetrage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface PieceMetrageRepository extends JpaRepository<PieceMetrage, Long> {
    List<PieceMetrage> findByLastModifiedDateAfterOrderByLastModifiedDateAsc(LocalDateTime since);
}
