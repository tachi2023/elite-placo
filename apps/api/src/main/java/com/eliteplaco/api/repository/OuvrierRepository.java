package com.eliteplaco.api.repository;

import com.eliteplaco.api.entity.Ouvrier;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface OuvrierRepository extends JpaRepository<Ouvrier, Long> {
    List<Ouvrier> findByLastModifiedDateAfterOrderByLastModifiedDateAsc(LocalDateTime since);
}
