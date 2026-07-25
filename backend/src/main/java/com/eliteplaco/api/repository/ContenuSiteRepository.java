package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.ContenuSite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ContenuSiteRepository extends JpaRepository<ContenuSite, Integer> {
    List<ContenuSite> findByTypeOrderByOrdreAsc(ContenuSite.TypeContenu type);
    Optional<ContenuSite> findByCle(String cle);
}
