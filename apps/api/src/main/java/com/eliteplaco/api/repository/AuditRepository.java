package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.Audit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AuditRepository extends JpaRepository<Audit, Long> {
    List<Audit> findByChantierIdOrderByDateHeureDesc(Long chantierId);
}
