package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.LienSuiviClient;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface LienSuiviClientRepository extends JpaRepository<LienSuiviClient, Long> {
    Optional<LienSuiviClient> findByCodePublicAndActifTrue(String codePublic);
    Optional<LienSuiviClient> findByChantierIdAndActifTrue(Long chantierId);
}
