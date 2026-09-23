package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.AvisClient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AvisClientRepository extends JpaRepository<AvisClient, Long> {
    List<AvisClient> findByStatutOrderByDatePublicationDesc(AvisClient.Statut statut);
    List<AvisClient> findAllByOrderByDateCreationDesc();
}
