package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.FicheMetrage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FicheMetrageRepository extends JpaRepository<FicheMetrage, Long> {
    List<FicheMetrage> findByChantierId(Long chantierId);
}
