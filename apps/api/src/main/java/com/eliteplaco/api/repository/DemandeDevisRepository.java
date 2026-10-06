package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.DemandeDevis;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DemandeDevisRepository extends JpaRepository<DemandeDevis, Long> {
    List<DemandeDevis> findAllByOrderByDateCreationDesc();
}
