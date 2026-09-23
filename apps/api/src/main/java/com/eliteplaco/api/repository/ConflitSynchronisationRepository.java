package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.ConflitSynchronisation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConflitSynchronisationRepository extends JpaRepository<ConflitSynchronisation, Long> {
    Optional<ConflitSynchronisation> findByOperationId(String operationId);
    List<ConflitSynchronisation> findByStatutOrderByDateCreationDesc(ConflitSynchronisation.Statut statut);
}
