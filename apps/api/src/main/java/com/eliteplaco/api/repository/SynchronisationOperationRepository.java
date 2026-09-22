package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.SynchronisationOperation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SynchronisationOperationRepository extends JpaRepository<SynchronisationOperation, Long> {
    Optional<SynchronisationOperation> findByOperationId(String operationId);
}
